From: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Sat, 03 May 2008 11:43:46 +0200
Message-ID: <481C33D2.2090308@ya.bofh.cz>
References: <20080503071651.GA3313@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlantis.mitranet.cz ([62.240.190.34]:46242 "EHLO
	atlantis.mitranet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305AbYECJnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 05:43:53 -0400
In-Reply-To: <20080503071651.GA3313@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Jan 'yanek' Bortl wrote, On 05/01/2008 05:49 PM:
> 
>> Hi,
> 
> Hi,
>> I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:
> 
> Does this mean the bug triggers in 2.6.25 and later, but not in 2.6.24?
> If so, is it possible to reproduce this e.g. with 2.6.25-rc6?

I firstly discovered this on 2.6.22-6~bpo40+1 (debian's backports), but I'm 
not sure if that was same thing (it is long ago).

Now i tested on test machine with these kernels:
2.6.24, 2.6.24.6 
(http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/netconsole-2.6.24.6-slon.txt), 
2.6.25

I can test anything you want.

  > Very nice description and logs, but alas I'm not able to test it, so
> a few questions:
> 
> - there are quite a lot of networking modules loaded like bonding or
> ifb: are there some other scripts (especially with virtual devices)?

I kicked them out now (ifb, vlan, bonding). Problem persist.

  +--------+           eth1 +---------+ eth2
  | laptop |----------------| router  |-----
  +--------+                +---------+
  laptop has address 192.168.243.10


> - could you send vlan and routing rules on this router?

http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/ipa-2.6.25-slon-00000-ge4c576b.txt
http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/ipro-2.6.25-slon-00000-ge4c576b.txt

> - does it always break with the same traces?

Yes.

Another run (without that modules): 
http://ya.bofh.cz/archive/kernel-2.6-htbcrash/2/netconsole-2.6.25-slon-00000-ge4c576b.txt


-- 
Jan 'yanek' Bortl <yanek [at] ya.bofh. cz>
http://ya.bofh.cz/ | jab: yanek [at] mitranet. cz
-----------------------------------------------------------------
"Maybe one day you will learn that your way is not the only way."
                                         Opher [StarGate: The Nox]
