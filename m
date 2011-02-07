From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4 0/5] net: Unified offload configuration
Date: Tue, 8 Feb 2011 00:12:50 +0100
Message-ID: <20110207231250.GA5068@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl> <20110207.133721.48496023.davem@davemloft.net> <20110207224937.GA32549@rere.qmqm.pl> <20110207.145259.246536239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38205 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240Ab1BGXMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Feb 2011 18:12:51 -0500
Content-Disposition: inline
In-Reply-To: <20110207.145259.246536239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 07, 2011 at 02:52:59PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 7 Feb 2011 23:49:37 +0100
> > What driver did you get this output from?
> NIU, which sets NETIF_F_HW_CSUM in netdev->features, which is
> absolutely correct.

Quick look at niu_process_rx_pkt() reveals that if you disable
TX checksumming you will also get 'rx-checksumming: off' from ethtool,
but RX checksumming will still be used.

Best Regards,
Micha=B3 Miros=B3aw
