From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 35/71] skge/sky2/mv643xx/pxa168: Move the Marvell
 Ethernet drivers
Date: Sun, 31 Jul 2011 15:27:17 -0700
Message-ID: <1312151237.11635.5.camel@Joe-Laptop>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-36-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110731151116.647e9974@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sachin Sanap <ssanap@marvell.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4408 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991Ab1GaW1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 18:27:19 -0400
In-Reply-To: <20110731151116.647e9974@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-31 at 15:11 -0700, Stephen Hemminger wrote:
> On Sat, 30 Jul 2011 20:26:54 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> >  MARVELL MWIFIEX WIRELESS DRIVER
> > @@ -5816,8 +5816,7 @@ SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
> >  M:	Stephen Hemminger <shemminger@linux-foundation.org>
> >  L:	netdev@vger.kernel.org
> >  S:	Maintained
> > -F:	drivers/net/skge.*
> > -F:	drivers/net/sky2.*
> > +F:	drivers/net/ethernet/marvell/sk*
> The old SysKonnect fddi driver should probably be moved in there
> as well. It is called skfp.c

fddi isn't ethernet so I think skfp.c should not be moved there.


