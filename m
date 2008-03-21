From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-rc5-mm1
Date: Fri, 21 Mar 2008 13:12:05 +0100
Message-ID: <20080321121205.GG25225@elte.hu>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org> <20080311202300.GA8957@vino.hallyn.com> <20080311133920.68dc410b.akpm@linux-foundation.org> <64bb37e0803121233v30d12a58i77a1e23fd02ea6f2@mail.gmail.com> <20080312124420.3ba8c3d7.akpm@linux-foundation.org> <64bb37e0803121301u6f836710m9ebb30e065751bec@mail.gmail.com> <64bb37e0803131505u7ae920fdvbbed005cbeb8c98e@mail.gmail.com> <20080313153528.a11795b7.akpm@linux-foundation.org> <1205449809.19403.40.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Torsten Kaiser <just.for.lkml@googlemail.com>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Badari Pulavarty <pbadari@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756268AbYCUMMa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1205449809.19403.40.camel@dyn9047017100.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Badari Pulavarty <pbadari@gmail.com> wrote:

> Yes. I found the following patch to be the culprit.
> 
> sched: make sure jiffies is up to date before calling __update_rq_clock
> ()

thanks Badari, i've backed out this patch.

	Ingo
