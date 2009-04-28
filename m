From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Tue, 28 Apr 2009 16:57:55 +0400
Message-ID: <20090428125755.GA5242@night.netis.ru>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:50065 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbZD1M6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 08:58:21 -0400
Content-Disposition: inline
In-Reply-To: <20090427054103.GA27529@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 09:41:03AM +0400, Alexander V. Lukyanov wrote:
> On Wed, Apr 22, 2009 at 09:57:35AM +0400, Alexander V. Lukyanov wrote:
> > unregister_netdevice: waiting for eth0.2 to become free. Usage count = 4
> > 
> > eth0.2 is a vlan interface, eth0 is 02:00.0 Ethernet controller: Realtek
> > Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet
> > controller (rev 01)
> 
> Ok, now I did manually 'vconfig rem eth0.2' and I get these repeated messages.
> How do I find out what exactly holds the interface being used?

BTW, it looks like all vlan interfaces (I have many of them) have similar
problem, when it happens - every few days:

unregister_netdevice: waiting for eth0.907 to become free. Usage count = 20

and when I run a `vconfig rem', I cannot run another one. It s(t)ucks.

-- 
   Alexander..
