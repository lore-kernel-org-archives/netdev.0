From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Wed, 24 Oct 2007 01:38:15 -0400
Message-ID: <20071024053815.GC28298@redhat.com>
References: <11931515302013-git-send-email-ajax@redhat.com> <471E1ECD.80002@intel.com> <1193156487.26974.39.camel@localhost.localdomain> <471E2AD0.1000500@intel.com> <471E5C21.8030908@garzik.org> <20071023212026.GF7793@redhat.com> <471E7DCA.9030700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Adam Jackson <ajax@redhat.com>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbXJXFlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 01:41:10 -0400
Content-Disposition: inline
In-Reply-To: <471E7DCA.9030700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 04:03:38PM -0700, Kok, Auke wrote:
 > Dave Jones wrote:
 > > On Tue, Oct 23, 2007 at 04:40:01PM -0400, Jeff Garzik wrote:
 > > 
 > >  > > In any case, this patch should not be merged. We often send it around to users to
 > >  > > debug their issue in case it involves eeproms, but merging it will just conceal
 > >  > > the real issue and all of a sudden a flood of people stop reporting *real* issues
 > >  > > to us.
 > >  > 
 > >  > Sorry, I disagree.  Just as with e100, if there is a clear way the user 
 > >  > can recover their setup -- and Adam says his was effective -- I don't 
 > >  > see why we should be denying users the ability to use their own hardware.
 > >  
 > > Indeed. This is a common enough problem that not including it causes more pain
 > > than its worth.  I have two affected boxes myself that I actually thought
 > > the hardware was dead before I tried ajax's patch.
 > 
 > 
 > look: You should have reported this to us and you didn't. Now you are using the
 > fact that you did not report it as an argument which is out of place.

you're missing the point.  It looks like a hardware failure. Why would I report this? 

 > why do you say it is common? how often have you seen this and not reported it back
 > to our support? are you willingly trying to frustrate this issue?

Not at all. The only frustration here is that I used to have a kernel that
worked, upgraded, and thought that my hardware was broken.
How many other users thought the same ?

	Dave

-- 
http://www.codemonkey.org.uk
