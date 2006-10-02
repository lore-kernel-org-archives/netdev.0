From: Badari Pulavarty <pbadari@gmail.com>
Subject: Re: Network problem with 2.6.18-mm1 ?
Date: Mon, 02 Oct 2006 16:17:51 -0700
Message-ID: <1159831071.5039.19.camel@dyn9047017100.beaverton.ibm.com>
References: <20060928013724.GA22898@us.ibm.com> <451B2D29.9040306@intel.com>
	 <20060928185222.GB3352@us.ibm.com>
	 <4807377b0609281410p28d445c8mc32e7d2cb71221ab@mail.gmail.com>
	 <20060929005205.GA3876@us.ibm.com>
	 <4807377b0609291108x84f39c6ic4c669fd91f8fcd4@mail.gmail.com>
	 <m1ejtui73g.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Sukadev Bhattiprolu <sukadev@us.ibm.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:23730 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S965517AbWJBXSX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 19:18:23 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>, akpm@osdl.org,
	adurbin@google.com, ak@suse.de
In-Reply-To: <m1ejtui73g.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 17:30 -0600, Eric W. Biederman wrote:
....
> 
> So it looks like the kernel moved the ioapics.
> 
> The following patch in 2.6.18-mm1 is known to have that effect.
> x86_64-mm-insert-ioapics-and-local-apic-into-resource-map
> 
> Can you please try reverting that one patch?
> 
> There is a fix an updated version of that patch I think in -mm2
> but I haven't had a chance to see if it fixes the problem yet.
> 

Bingo !! Reverting this patch fixed my networking problem on
2.6.18-mm2.

Thanks,
Badari


