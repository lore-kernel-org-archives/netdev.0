From: Ingo Molnar <mingo@elte.hu>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 12:52:36 +0100
Message-ID: <20081127115236.GE29013@elte.hu>
References: <492DD792.6080302@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Arjan van de Ven <arjan@linux.intel.com>,
	Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753443AbYK0LxY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <492DD792.6080302@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> Rank 8: mtrr_trim_uncached_memory (warning)
> 	Reported 227 times (619 total reports)
> 	There is a high number of machines where our MTRR checks 
> 	trigger. I suspect we are too picky in accepting the MTRR 
> 	configuration.

the warning here means: "the BIOS messed up but we fixed it up for 
you just fine".

Should we print a DMI descriptor so that it can be tracked back to the 
bad BIOSen in question? Or should we (partially) silence the warning 
itself? Those BIOS bugs need fixing really: older kernels will boot up 
with bad MTRR settings - resulting in a super-slow system or other 
weirdnesses. We can tone down the message so that it doesnt show up in 
kerneloops.org. It's up to you.

	Ingo
