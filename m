From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 10:01:43 -0800
Message-ID: <492EE087.80708@linux.intel.com>
References: <492DD792.6080302@linux.intel.com> <20081127115236.GE29013@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62239 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbYK0SBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 13:01:50 -0500
In-Reply-To: <20081127115236.GE29013@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Arjan van de Ven <arjan@linux.intel.com> wrote:
> 
>> Rank 8: mtrr_trim_uncached_memory (warning)
>> 	Reported 227 times (619 total reports)
>> 	There is a high number of machines where our MTRR checks 
>> 	trigger. I suspect we are too picky in accepting the MTRR 
>> 	configuration.
> 
> the warning here means: "the BIOS messed up but we fixed it up for 
> you just fine".

I don't believe that right now.
we see so many of these, including many "there's no MTRRs at all",
that I am seriously suspecting that our code is just incorrect somehow
and triggering too much.

