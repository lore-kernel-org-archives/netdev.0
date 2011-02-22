From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: avoid initial "Features changed" message
Date: Tue, 22 Feb 2011 15:43:37 +0100
Message-ID: <20110222144337.GA25132@rere.qmqm.pl>
References: <20110218.120617.71104636.davem@davemloft.net> <864ebe4e8085d1782e90137e146bb95e38e4c718.1298385559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33170 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab1BVOni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 09:43:38 -0500
Content-Disposition: inline
In-Reply-To: <864ebe4e8085d1782e90137e146bb95e38e4c718.1298385559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 22, 2011 at 03:42:06PM +0100, Micha=B3 Miros=B3aw wrote:
> Avoid "Features changed" message and ndo_set_features call on device
> registration caused by automatic enabling of GSO and GRO. Driver shou=
ld
> have already enabled hardware offloads it set in features, so the
> ndo_set_features() is not needed at registration time unless features
> change because of other dependencies.
[cut patch]

Ah. This depends on 'Fix "(unregistered net_device): Features changed" =
message'
patch I sent couple days ago.

Best Regards,
Micha=B3 Miros=B3aw
