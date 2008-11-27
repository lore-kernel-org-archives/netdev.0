From: Ingo Molnar <mingo@elte.hu>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 21:18:36 +0100
Message-ID: <20081127201836.GA16869@elte.hu>
References: <492DD792.6080302@linux.intel.com> <20081127115236.GE29013@elte.hu> <492EE087.80708@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:38745 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbYK0UT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 15:19:27 -0500
Content-Disposition: inline
In-Reply-To: <492EE087.80708@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> Ingo Molnar wrote:
>> * Arjan van de Ven <arjan@linux.intel.com> wrote:
>>
>>> Rank 8: mtrr_trim_uncached_memory (warning)
>>> 	Reported 227 times (619 total reports)
>>> 	There is a high number of machines where our MTRR checks 	trigger. I 
>>> suspect we are too picky in accepting the MTRR 	configuration.
>>
>> the warning here means: "the BIOS messed up but we fixed it up for you 
>> just fine".
>
> I don't believe that right now. we see so many of these, including 
> many "there's no MTRRs at all", that I am seriously suspecting that 
> our code is just incorrect somehow and triggering too much.

well we looked at existing reports and Linux was right to fix them up. 
Show us one that is incorrect, then we can fix it up.

the "no MTRR's" are vmware/(also qemu?) guests not implementing a full 
CPU emulation.

	Ingo
