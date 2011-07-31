From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next v2 35/71] skge/sky2/mv643xx/pxa168: Move the Marvell
 Ethernet drivers
Date: Sun, 31 Jul 2011 15:11:16 -0700
Message-ID: <20110731151116.647e9974@nehalam.ftrdhcpuser.net>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-36-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34695 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab1GaWLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 18:11:06 -0400
In-Reply-To: <1312082850-24914-36-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Jul 2011 20:26:54 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

>  MARVELL MWIFIEX WIRELESS DRIVER
> @@ -5816,8 +5816,7 @@ SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
>  M:	Stephen Hemminger <shemminger@linux-foundation.org>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> -F:	drivers/net/skge.*
> -F:	drivers/net/sky2.*
> +F:	drivers/net/ethernet/marvell/sk*

The old SysKonnect fddi driver should probably be moved in there
as well. It is called skfp.c

I don't maintain that one, it is unmaintained.

