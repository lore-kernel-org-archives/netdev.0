From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 06 Jun 2006 13:30:12 -0400
Message-ID: <x494pyyw5sr.fsf@segfault.boston.redhat.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>
	<20060605231125.12584.17039.stgit@gitlost.site>
	<20060606135217.GA21969@hmsreliant.homelinux.net>
	<1149611965.13635.19.camel@strongmad>
	<20060606170513.GB21969@hmsreliant.homelinux.net>
	<4485B8EC.4090603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:29879 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750701AbWFFRaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:30:52 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4485B8EC.4090603@intel.com> (Auke Kok's message of "Tue, 06
 Jun 2006 10:18:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:

auke-jan.h.kok> Neil Horman wrote:
>> On Tue, Jun 06, 2006 at 09:39:25AM -0700, Mitch Williams wrote:
>>> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:


auke-jan.h.kok> [snip]


>>> However, just for the sake of correctness (and paranoia), I'll whip up
>>> another patch that does this check.
>>> 
>> Thanks for the quick feedback!
>> Regards
>> Neil
>> 
>>> Jeff, please do not commit this patch.

auke-jan.h.kok> Jeff,

auke-jan.h.kok> I've popped the patch off from our gitserver, so you can pull the two
auke-jan.h.kok> outstanding patches while we revamp this one.

Would you please send patches to this list?  I'd certainly like to review
them.  I don't think the problem needs solving in the e1000 driver.  I
think it is an issue that should be handled properly by netpoll.

-Jeff
