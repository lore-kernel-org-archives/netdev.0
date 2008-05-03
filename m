From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Sat, 3 May 2008 09:16:51 +0200
Message-ID: <20080503071651.GA3313@ami.dom.local>
References: <20080501145239.GA20284__27061.693944461$1209657574$gmane$org@atlantis.mitranet.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:56341 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbYECHS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 03:18:27 -0400
Received: by ug-out-1314.google.com with SMTP id h3so236731ugf.16
        for <netdev@vger.kernel.org>; Sat, 03 May 2008 00:18:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080501145239.GA20284__27061.693944461$1209657574$gmane$org@atlantis.mitranet.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan 'yanek' Bortl wrote, On 05/01/2008 05:49 PM:

> Hi,

Hi,
> 
> I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:

Does this mean the bug triggers in 2.6.25 and later, but not in 2.6.24?
If so, is it possible to reproduce this e.g. with 2.6.25-rc6?

> 
> Network configuration:
> 
> +--------+         vlan20 +---------+ vlan80
> | laptop |----------------| router  |-----
> +--------+                +---------+ 
> laptop has address 192.168.243.10
> 
> Reproduce HOWTO:

Very nice description and logs, but alas I'm not able to test it, so
a few questions:

- there are quite a lot of networking modules loaded like bonding or
ifb: are there some other scripts (especially with virtual devices)?
- could you send vlan and routing rules on this router?
- does it always break with the same traces?

Thanks,
Jarek P.
