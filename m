From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Mon, 7 Mar 2011 09:32:02 -0500
Message-ID: <20110307143202.GS11864@gospo.rdu.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160Ab1CGOcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 09:32:43 -0500
Content-Disposition: inline
In-Reply-To: <20110307125059.GA6053@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 01:51:00PM +0100, Jiri Pirko wrote:
> Recent patch "bonding: move processing of recv handlers into
> handle_frame()" caused a regression on following net scheme:
> 
> eth0 - bond0 - bond0.5
> 
> where arp monitoring is happening over vlan. This patch fixes it by
> reinjecting the arp packet into bonding slave device so the bonding
> rx_handler can pickup and process it.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Thanks, Jiri.  I will test and make sure it works correctly now.  I know
several users who would be quite disappointed if this feature was
removed.

