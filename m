From: Matt Mackall <mpm@selenic.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Mon, 26 Jul 2004 16:06:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040726210613.GR5414@waste.org>
References: <20040724223310.68910.qmail@web53004.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Niranjan <niranjan_cs2905@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20040724223310.68910.qmail@web53004.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 24, 2004 at 03:33:10PM -0700, Niranjan wrote:
> Hi,
> I am working on Linux Kernel 2.4.25. I am trying to
> add cryptoapi (cryptoapi-0.1.0) support to wireless
> lan driver (linux-wlan-ng-0.2.1.pre14) of prism-based
> cards. Cardctl version is 3.1.31.
> When I am using "null" as a encryption cipher to check
> the coding sequence, everything is working fine. But
> when I change it to any other cipher for e.g.
> "blowfish" or "rc5", it is giving kernel panic. I have
> included Ksymoops extract from the kernel Ooops
> reports below.
> Can anyone please help me in what can be possible
> error by looking at the log ? 
> I will greatly appreciate any help in this matter.

The cryptoapi currently decides to sleep at various points internally
when digesting a block which is probably what you're seeing.

-- 
Mathematics is the supreme nostalgia of our time.
