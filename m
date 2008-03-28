From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 15:01:24 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0803281500100.14670@woody.linux-foundation.org>
References: <47ED3F1A.1090101@linux.intel.com>  <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>  <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org>  (sfid-20080328_205203_254278_BF9EB41F) <1206738071.22530.80.camel@johannes.berg>
  <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org> <1206740581.22530.83.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Dmitry Torokhov <dtor@mail.ru>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758787AbYC1WC0@vger.kernel.org>
In-Reply-To: <1206740581.22530.83.camel@johannes.berg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 28 Mar 2008, Johannes Berg wrote:
> 
> I tend to think it's actually a regression, I've done exactly what I
> described there dozens of times before on older kernels and it doesn't
> seem to be a race condition, X always locks the input device and I never
> had trouble with that before.

Ahh. So it's easily repeatable for you.. Do you think you could bisect it? 
At least a few runs? Even a partial bisection will give a nice (== much 
smaller) range of commits to be blamed, and might tell us why it started 
happening..

			Linus
