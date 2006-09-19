From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 03/23] e100: Add debugging code for cb cleaning and csum
 failures.
Date: Tue, 19 Sep 2006 15:21:34 -0700
Message-ID: <45106D6E.6060602@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172838.4605.35958.stgit@gitlost.site> <20060919213336.GA29362@redhat.com> <451063D2.7020301@pobox.com> <20060919214612.GC31621@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10686 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1751003AbWISWXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 18:23:11 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060919214612.GC31621@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> On Tue, Sep 19, 2006 at 05:40:34PM -0400, Jeff Garzik wrote:
>  > Dave Jones wrote:
>  > > On Tue, Sep 19, 2006 at 10:28:38AM -0700, Kok, Auke wrote:
>  > >  > +			add_taint(TAINT_MACHINE_CHECK);
>  > > 
>  > > I object to this flag being abused this way.
>  > > A corrupt EEPROM on a network card has _nothing_ to do with
>  > > a CPU machine check exception.
>  > 
>  > Fair enough.  Better suggestions?
>  > 
>  > I think it's fair to set _some_ taint flag, perhaps a new one, on a 
>  > known corrupted firmware.  But if others disagree, I'll follow the 
>  > consensus here.
> 
> I don't object to a new flag, but overloading an existing flag that has
> established meaning just seems wrong to me.
> 
> Question is how many more types of random hardware failures are there
> that we'd like to do similar things for ?
> Perhaps a catch-all "H"ardware failure flag for assorted brokenness
> would be better than a proliferation of flags?

fine with me. I don't have a strong preference for any specific flag, but 
"H"ardware sounds reasonable.

Auke
