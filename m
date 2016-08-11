From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out
 systim	sanitization
Date: Thu, 11 Aug 2016 11:48:09 -0400
Message-ID: <20160811154809.GA56642@redhat.com>
References: <1469292274-59237-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-2-git-send-email-jarod@redhat.com>
 <8F4C390AFA9F4444A4AA77F4A3BEC78A190E7843@HASMSX110.ger.corp.intel.com>
 <20160727150155.GF36313@redhat.com>
 <20160802013214.GU36313@redhat.com>
 <309B89C4C689E141A5FF6A0C5FB2118B81F6579E@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Avargil, Raanan" <raanan.avargil@intel.com>,
	"Hall, Christopher S" <christopher.s.hall@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34107 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932267AbcHKPsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 11:48:14 -0400
Received: by mail-yw0-f169.google.com with SMTP id z8so4644450ywa.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 08:48:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B81F6579E@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 02, 2016 at 07:33:01AM +0000, Brown, Aaron F wrote:
> > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> > Behalf Of Jarod Wilson
> > Sent: Monday, August 1, 2016 6:32 PM
> > To: Avargil, Raanan <raanan.avargil@intel.com>
> > Cc: Hall, Christopher S <christopher.s.hall@intel.com>;
> > netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> > kernel@vger.kernel.org
> > Subject: Re: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out
> > systim sanitization
> > 
> > On Wed, Jul 27, 2016 at 11:01:55AM -0400, Jarod Wilson wrote:
> > > On Wed, Jul 27, 2016 at 02:09:13PM +0000, Avargil, Raanan wrote:
> > > >> This is prepatory work for an expanding list of adapter families that have
> > occasional ~10 hour clock jumps when being used for PTP. Factor out the
> > sanitization function and convert to using a feature (bug) flag, per suggestion
> > from Jesse Brandeburg.
> > > >>
> > > >> Littering functional code with device-specific checks is much messier
> > than simply checking a flag, and having device-specific init set flags as
> > needed.
> > > >> There are probably a number of other cases in the e1000e code that
> > could/should be converted similarly.
> > > >
> > > > Looks ok to me.
> > > > Adding Chris who asked what happens if we reach the max retry counter
> > (E1000_MAX_82574_SYSTIM_REREAD)?
> > > > This counter is set to 50.
> > > > Can you, for testing purposes, decreased this value (or even set it to 0)
> > and see what happens?
> > >
> > > Unfortunately, I don't have direct access to the affected hardware myself,
> > > so I'd have to prep a test build, hand it off to someone and play relay. I
> > > could do that, but it'd have some lag and possible multiple round-trips...
> > > Anyone inside Intel have hardware handy to test on? :p
> > 
> > Was tied up with other work the middle of last week, then on vacation for
> > a bit. There was some testing feedback provided from someone at neither
> > Red Hat or Intel, but I'm not sure where it leaves us right now. What
> > needs to happen next?
> 
> Probably nothing else needs to be done on your end.  I was out for the last week and a half and am now running the patches through a series of regression test covering a fair number of the different e1000e parts.  I will also try to duplicate Tim Woodford' success on a NUC with an i218 in my lab.  Assuming nothing jumps out at me I'll probably give it a tested-by later this week so that Jeff can push it on up.

Looking for a status update on this one, not seeing it pushed to DaveM
just yet.

-- 
Jarod Wilson
jarod@redhat.com
