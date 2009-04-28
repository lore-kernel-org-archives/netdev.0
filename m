From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Tue, 28 Apr 2009 22:49:58 +0200
Message-ID: <49F76BF6.4040709@gmail.com>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:48659 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbZD1UvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 16:51:22 -0400
In-Reply-To: <20090428125755.GA5242@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander V. Lukyanov wrote, On 04/28/2009 02:57 PM:

> On Mon, Apr 27, 2009 at 09:41:03AM +0400, Alexander V. Lukyanov wrote:
>> On Wed, Apr 22, 2009 at 09:57:35AM +0400, Alexander V. Lukyanov wrote:
>>> unregister_netdevice: waiting for eth0.2 to become free. Usage count = 4
>>>
>>> eth0.2 is a vlan interface, eth0 is 02:00.0 Ethernet controller: Realtek
>>> Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet
>>> controller (rev 01)
>> Ok, now I did manually 'vconfig rem eth0.2' and I get these repeated messages.
>> How do I find out what exactly holds the interface being used?
> 
> BTW, it looks like all vlan interfaces (I have many of them) have similar
> problem, when it happens - every few days:
> 
> unregister_netdevice: waiting for eth0.907 to become free. Usage count = 20
> 
> and when I run a `vconfig rem', I cannot run another one. It s(t)ucks.
> 


Do you mean if you wait a bit longer (until the first one is really removed)
before running another one, it doesn't s(t)uck? Is there a change e.g. wrt.
2.6.28?

Jarek P.
