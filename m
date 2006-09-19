From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 03/23] e100: Add debugging code for cb cleaning and csum failures.
Date: Tue, 19 Sep 2006 17:46:12 -0400
Message-ID: <20060919214612.GC31621@redhat.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172838.4605.35958.stgit@gitlost.site> <20060919213336.GA29362@redhat.com> <451063D2.7020301@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33444 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752088AbWISVqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:46:30 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <451063D2.7020301@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2006 at 05:40:34PM -0400, Jeff Garzik wrote:
 > Dave Jones wrote:
 > > On Tue, Sep 19, 2006 at 10:28:38AM -0700, Kok, Auke wrote:
 > >  > +			add_taint(TAINT_MACHINE_CHECK);
 > > 
 > > I object to this flag being abused this way.
 > > A corrupt EEPROM on a network card has _nothing_ to do with
 > > a CPU machine check exception.
 > 
 > Fair enough.  Better suggestions?
 > 
 > I think it's fair to set _some_ taint flag, perhaps a new one, on a 
 > known corrupted firmware.  But if others disagree, I'll follow the 
 > consensus here.

I don't object to a new flag, but overloading an existing flag that has
established meaning just seems wrong to me.

Question is how many more types of random hardware failures are there
that we'd like to do similar things for ?
Perhaps a catch-all "H"ardware failure flag for assorted brokenness
would be better than a proliferation of flags?

	Dave

