From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 05:47:28 +0300
Message-ID: <20080617023852.M86134@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb> <4856DB1D.80503@cosmosbay.com> <20080616213419.M212@visp.net.lb> <4856DE1F.4090001@cosmosbay.com> <4856DEA7.9060506@cosmosbay.com> <20080616220004.M32074@visp.net.lb> <48571EB2.50301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:53384 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbYFQCrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 22:47:35 -0400
In-Reply-To: <48571EB2.50301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008 04:17:22 +0200, Eric Dumazet wrote

> How often is iptables used on your machine ?
On this machine, just 3-4 rules. As i mention before, unloading iptables
modules didn't help.


> > since the profile was taken. Results may be inaccurate.
> > samples  %        symbol name
> > 144449   25.7521  e1000_irq_enable
> 
> I wonder why this one is called so often. If your
> interface is really flooded with packets, we should not
> exit from NAPI polling...

At that moments values RX 82Kpps, TX also around 82Kpps
339 Mbps RX, 337 Mbps TX
Average packet ~516 bytes


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

