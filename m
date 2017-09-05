From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 915f3e3f76 ("mac80211_hwsim: Replace bogus hrtimer clockid"):
 BUG: kernel reboot-without-warning in test stage
Date: Tue, 5 Sep 2017 09:12:40 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709050910150.1900@nanos>
References: <59ade247.WzhbxWeytBOa6Xu4%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        wfg@linux.intel.com
To: kernel test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:43981 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdIEHNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 03:13:01 -0400
In-Reply-To: <59ade247.WzhbxWeytBOa6Xu4%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Sep 2017, kernel test robot wrote:

> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> 
> commit 915f3e3f76c05b2da93c4cc278eebc2d9219d9f4
> Author:     Thomas Gleixner <tglx@linutronix.de>
> AuthorDate: Sat Feb 25 11:27:37 2017 +0100
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Sat Feb 25 09:48:16 2017 -0800
> 
>     mac80211_hwsim: Replace bogus hrtimer clockid
>     
>     mac80211_hwsim initializes a hrtimer with clockid CLOCK_MONOTONIC_RAW.
>     That's not supported.
>     
>     Use CLOCK_MONOTNIC instead.

Sorry, no. That bisect is completely bogus. The commit in question merily
replaces the unsupported clockid with a valid one.

Thanks,

	tglx
