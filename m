From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_release_data oops
Date: Fri, 25 May 2012 17:11:44 +0200
Message-ID: <1337958704.3347.44.camel@edumazet-glaptop>
References: <4FBF9876.032A7B.32344@m12-16.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: kendo <kendo999@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62219 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124Ab2EYPLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 11:11:48 -0400
Received: by eaak11 with SMTP id k11so271362eaa.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 08:11:47 -0700 (PDT)
In-Reply-To: <4FBF9876.032A7B.32344@m12-16.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-25 at 22:19 +0800, kendo wrote:
> I use the Linux kernel 2.6..38.8,found a bug when free skb,This failure may occur because what was it? Can you give some suggestions, thanks!!!!
> 
> Best reguards.
> 
> ---------------------------------------------------------------
> 
> May 25 19:30:54 AnShion <9> klogd: [164619.378640] BUG: unable to handle kernel paging request at 000095a3
> May 25 19:30:54 AnShion <9> klogd: [164619.454609] IP: [<c01c2353>] put_page+0x3/0x40
> May 25 19:30:54 AnShion <12> klogd: [164619.508726] *pde = 00000000 
> May 25 19:30:54 AnShion <8> klogd: [164619.544185] Oops: 0000 [#1] SMP 
> May 25 19:30:54 AnShion <8> klogd: [164619.583891] last sysfs file: /sys/devices/virtual/net/tunl_FJ/uevent
> May 25 19:30:54 AnShion <12> klogd: [164619.660716] Modules linked in:


>  dpi_engine ipmi_watchdog nf_connmark ip_set_hash_netiface ip_set_hash_net ip_set_hash_ip xt_set ip_set \

> xt_hashrate xt_dpi xt_pcc xt_nth xt_random xt_nflog xt_replace igb e1000e 

Looks like you use a bunch of alien modules.

netdev is not the place to discuss of their bugs.
