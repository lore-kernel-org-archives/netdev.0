From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG/ spinlock lockup, 2.6.24
Date: Fri, 15 Feb 2008 21:21:54 +0100
Message-ID: <47B5F462.40603@gmail.com>
References: <20080215150044.M24489@visp.net.lb> <e2e108260802150724k4e5e6089mcb603b524157a9bc@mail.gmail.com> <20080215193854.M55147@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:39565 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbYBOUSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 15:18:37 -0500
Received: by fk-out-0910.google.com with SMTP id z23so862196fkz.5
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 12:18:35 -0800 (PST)
In-Reply-To: <20080215193854.M55147@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 02/15/2008 08:42 PM:
...

> I have similar crashes on completely different hardware with same job (QOS), 
> so i think it is actually some nasty bug in networking.

Maybe you could try with some other debugging options? E.g. since lockdep
doesn't help - turn this off. Instead try some others, like these:

> # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> # CONFIG_DEBUG_KOBJECT is not set
> # CONFIG_DEBUG_HIGHMEM is not set
> # CONFIG_DEBUG_VM is not set
> # CONFIG_DEBUG_LIST is not set
> # CONFIG_DEBUG_SG is not set
> # CONFIG_BOOT_PRINTK_DELAY is not set
> # CONFIG_DEBUG_STACKOVERFLOW is not set
> # CONFIG_DEBUG_STACK_USAGE is not set
> # CONFIG_DEBUG_RODATA is not set

Regards,
Jarek P.
