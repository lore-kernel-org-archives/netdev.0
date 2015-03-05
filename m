From: "Nikita N." <nikitan@operamail.com>
Subject: Re: brcmsmac not compliant to 802.11 for BCM4313
Date: Thu, 05 Mar 2015 10:50:44 -0800
Message-ID: <1425581444.688217.236062177.3E9A0D68@webmail.messagingengine.com>
References: <1424007136.2042747.227726249.45B6A0E2@webmail.messagingengine.com>
 <1424094835.3188168.228077393.0E2006F5@webmail.messagingengine.com>
 <54E2107F.4000709@broadcom.com>
 <1424112787.3303548.228201005.68F1D224@webmail.messagingengine.com>
 <54E24B48.80601@broadcom.com>
 <1424163814.3140549.228461101.1C2E5AB1@webmail.messagingengine.com>
 <1425483570.3947119.235432705.0D7855AE@webmail.messagingengine.com>
 <54F7486B.7050608@broadcom.com>
 <1425543782.472412.235829781.15C5ACE0@webmail.messagingengine.com>
 <54F824D2.9030504@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, brcm80211-dev-list@broadcom.com,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Pat Erley <pat-lkml@erley.org>, brudley@broadcom.com,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F824D2.9030504@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Arend,
thanks for answering, unfortunately the answers open new questions
indeed, if I may.

> > 1) What is assuring that proprietary "strict custom regulatory domain"
> > is not obsolete/deprecated and compliant to 802.11 regulations?
> This is a very hypothetical question. If regulation would indeed change 
> in such way we would have to release new firmware.

That is not hypothetical at all, since we do *NOT* know what that
proprietary regdomain is enforcing.
That "strict custom regulatory domain" is proprietary Broadcom, hence
nobody knows what is written inside it, following all sad&known
considerations that Pat Erley explained (that is also the answer to you
Pat)
Now, to verify that such proprietary regdomain is enforcing a legal and
compliant regdomain, we should know it's details.
Question, is it possible to know how/what is written in that proprietary
regdomain inside the firmware?

> > 2) Regulatory domains can by 802.11 regulation change dynamically within
> > time/country, why BCM4313 users are obliged to lock only on 1
> > proprietary regdomain?
> This is not mandatory. Using 1 restricted world regulatory domain is 
> fine as well as Pat Erley explained in his response.

Sorry, what is not mandatory?
It is not mandatory that users are obliged to lock only on 1 proprietary
regdomain?
Of course it is not, it is not fair nor compliant to any regulations I
know of - do you?
It is not mandatory that 802.11 regulations change? sure, but they
change, indeed.
It is not mandatory regdomains rules change? sure, but they change,
indeed.

> > 4) Has been done any step so far, to root the cause of this issue?
> I did hunt down a 4313 to do so and put it in my test laptop.
Thank you very much! :)
In the meantime, if you could please verify a possible solution coming
now to my mind.
I understood that Broadcom management doesn't want to give power
controls to user.
Very sad personally, but I don't see any help to that coming from you
(your managers).
So, maybe, do BCM4313 has more than 1 special proprietary preset
regdomain buried in the firmware?
If yes, it would be great if you could tell us (programmers) how we can
switch to any of those other preset regdomains.
So that we could test them, and find the one which best conform to our
local/country regulation.
It seems to me a fair compromise for solving that issue, isn't?

> > 5) Since I have spent money&time on that device, I would like at least
> > to monitor the work in progress done to root the cause of this issue -
> > how can I?
> 
> You could create a bugzilla item on kernel.org.

Sure will do.
As soon as someone from Broadcom QA Testing Team, will find that the
root cause of that issue depends on Linux kernel.
I guess I already did my best to try debugging and solving for *free* a
Broadcom issue which: 1) doesn't depend on me, 2) is locked down in a
proprietary firmware, 3) is protected by secrecy of proprietary Broadcom
informations.

Thanks & Greetings.

-- 
  Nikita N.
  nikitan@operamail.com


On Thu, Mar 5, 2015, at 01:41 AM, Arend van Spriel wrote:
> On 03/05/15 09:23, Nikita N. wrote:
> > Dear Arend,
> >
> >>> I tried recompile the regulatory domain database, those functions did
> >>> not retrieve the new values.
> >>> Whatever values I set for domain 00, the effect was null - BCM4313 kept
> >>> functioning independently.
> >> That is exactly what should happen. The brcmsmac driver applies a
> >> so-called strict custom regulatory domain and does not follow any
> >> regulatory domain provisioning.
> >
> > As I understand your words, the BCM4313 has a proprietary regdomain, a
> > so called "strict custom regulatory domain" buried in the firmware, and
> > finish.
> > That proprietary regdomain is applied when attaching brcmsmac Linux
> > driver.
> > But in other drivers, e.g. the wl driver, or ms-windows drivers all
> > versions, the BCM4313 doesn't apply that "strict custom regulatory
> > domain".
> > In all other drivers, the BCM4313 applies different regdomains and
> > relative power levels according to the system/OS.
> > So now, after your explanation, logic tells me, the BCM4313 regdomain is
> > locked only in the brcmsmac driver for Linux.
> > Instead it operates open and fully functional in the other drivers.
> > So now 3 more questions, if I'm allowed:
> > 1) What is assuring that proprietary "strict custom regulatory domain"
> > is not obsolete/deprecated and compliant to 802.11 regulations?
> 
> This is a very hypothetical question. If regulation would indeed change 
> in such way we would have to release new firmware.
> 
> > 2) Regulatory domains can by 802.11 regulation change dynamically within
> > time/country, why BCM4313 users are obliged to lock only on 1
> > proprietary regdomain?
> 
> This is not mandatory. Using 1 restricted world regulatory domain is 
> fine as well as Pat Erley explained in his response.
> 
> > 3) Why BCM4313 is locked only for brcmsmac?
> 
> I explained that in an earlier email. It was a requirement for getting 
> the driver open-sourced to avoid releasing proprietary code. For wl 
> driver that part is in the binary blob that runs on the host so it does 
> not need the restriction. Guess no further explanation is needed for the 
> windows driver.
> 
> >>> 2) MCS - 11n modulated frames are not detected in BCM4313 monitor mode -
> >>> I informed you about this issue more than 1 year ago, and again 2 weeks
> >>> ago.
> >>> The issue still reproduces, and no sign of any fix.
> >>> When/in what backports version, this issue is supposed to be fixed
> >>> finally?
> >> What is the deal about backports here. If there will be a fix it will be
> >> done upstream and eventually end up in a backports package. First need
> >> to root cause this issue.
> >
> > So now 2 more questions, if I'm allowed:
> 
> You're pushing the limit ;-)
> 
> > 4) Has been done any step so far, to root the cause of this issue?
> 
> I did hunt down a 4313 to do so and put it in my test laptop.
> 
> > 5) Since I have spent money&time on that device, I would like at least
> > to monitor the work in progress done to root the cause of this issue -
> > how can I?
> 
> You could create a bugzilla item on kernel.org.
> 
> Regards,
> Arend
> 
> > Thanks&  Greetings
> >
> > On Wed, Mar 4, 2015, at 10:01 AM, Arend van Spriel wrote:
> >> On 03/04/15 16:39, Nikita N. wrote:
> >>> Dear Arend,
> >>> as followup to my last inquiry, since it's passed more than 2 weeks, I'm
> >>> afraid I didn't receive any answer.
> >>
> >> Ok, you diverted my attention by presenting an absurd sense of reality.
> >> But let me put emotions aside and answer your questions below.
> >>
> >>> As from subject, I finally discovered that brcmsmac is not compliant to
> >>> 802.11 regulations for BCM4313.
> >>> So, as purchasing customer, and member of Linux users community, I try
> >>> to propose my questions to you again now, 3 in total:
> >>>
> >>> 1) Regulatory domain - you wrote "brcmsmac does assure tx power is
> >>> within regulatory limits by enforcing a world regulatory domain"
> >>> That affirmation is *FALSE*.
> >>> I spent the whole weekend putting brcmsmac under heavy trace, all
> >>> functions, above all the phy ones.
> >>> Some code "supposes" to enforce a regulatory domain, but the effect is
> >>> total null.
> >>> I tried recompile the regulatory domain database, those functions did
> >>> not retrieve the new values.
> >>> Whatever values I set for domain 00, the effect was null - BCM4313 kept
> >>> functioning independently.
> >>
> >> That is exactly what should happen. The brcmsmac driver applies a
> >> so-called strict custom regulatory domain and does not follow any
> >> regulatory domain provisioning.
> >>
> >> [87636.143361] cfg80211: Ignoring regulatory request set by core since
> >> the driver uses its own custom regulatory domain
> >>
> >>> The functions, phy and not, which are "supposed" to set the eeprom
> >>> registries for regdomain enforce, have effect null - the BCM4313 kept
> >>> functioning independently.
> >>> I tried setting random numbers in those functions and registries, the
> >>> effect was null - the BCM4313 kept functioning independently.
> >>> At the edge of my frustration, I started commenting away from the code
> >>> those whole phy functions, the effect was null again - the BCM4313 kept
> >>> functioning independently.
> >>> I don't know for what Broadcom hw device were written and *tested* those
> >>> functions - but sure is, they do *NOT* work for BCM4313.
> >>> Could you please explain how/where the BCM4313 is supposed to "enforcing
> >>> a world regulatory domain" ?
> >>
> >> It is done in firmware.
> >>
> >>> 2) MCS - 11n modulated frames are not detected in BCM4313 monitor mode -
> >>> I informed you about this issue more than 1 year ago, and again 2 weeks
> >>> ago.
> >>> The issue still reproduces, and no sign of any fix.
> >>> When/in what backports version, this issue is supposed to be fixed
> >>> finally?
> >>
> >> What is the deal about backports here. If there will be a fix it will be
> >> done upstream and eventually end up in a backports package. First need
> >> to root cause this issue.
> >>
> >>> 3) I explicitly purchased this BCM4313 already 1 year ago, with the
> >>> following specs: 0x4313 rev 0x01 package 0x08, 3 cores ChipCommon,
> >>> IEEE802.11 and PCIe.
> >>> I have been searching for any technical datasheet specification document
> >>> about BCM4313 on Broadcom website and others.
> >>> Did not find any.
> >>> Could you please send me a detailed technical datasheet specification
> >>> document about BCM4313, for programming/dev purposes?
> >>
> >> That is all proprietary information.
> >>
> >> Regards.
> >> Arend
> >>
> >>>
> >>> On Tue, Feb 17, 2015, at 01:03 AM, Nikita N. wrote:
> >>>> Hi Arend,
> >>>>
> >>>>> brcmsmac does assure tx power is within regulatory limits by enforcing a
> >>>>> world regulatory domain. So what is not supported is modifying tx power
> >>>>> settings through user-space.
> >>>>
> >>>> Yes, I believe that could be right, *a* world regulatory domain looks
> >>>> indeed enforced, the USA one only, which is pre-set default inside
> >>>> EEPROM registries device, isn't it?
> >>>>
> >>>>> I know, but that driver is not fully open-source as it links in a binary
> >>>>> blob.
> >>>>
> >>>> AFAIK, also brcmsmac needs at least 2 firmware files to operate, without
> >>>> those nothing works.
> >>>> Isn't it the same concept?
> >>>>
> >>>>> I totally lost track of this one. I am using brcmsmac in monitor mode
> >>>>> using bcm43224 which captures 11n frames just fine. I will give it a try
> >>>>> with a bcm4313. The assoc response in your capture shows undefined MCS
> >>>>> set so maybe there really are no 11n MCS rates used (?).
> >>>>
> >>>> If that was a suggestion about to purchase a bcm43224 or any other
> >>>> Broadcom Corp. product, isn't really convincing, seen the overall
> >>>> support quality Customers are experiencing in here...
> >>>> About my capture file, in the case it was really incomplete someone
> >>>> could have informed me at least a year ago.
> >>>> But anyway no respectable QA Testing team needs a purchasing Customer to
> >>>> help in verifying such enormous issue, isn't it?
> >>>>
> >>>>> Our team consist of two man working full-time on the upstream linux
> >>>>> drivers. So our "customer care" is something that we try to deal with on
> >>>>> the side and admittedly things slip between the cracks.
> >>>>
> >>>> Really, *TWO* men? Are you kidding? Is that how much Broadcom Corp.
> >>>> values the Linux community?
> >>>> Needles to remind, even if Linux users don't pay for the OS license as
> >>>> Windows do, they do pay allright for any Broadcom hardware they
> >>>> purchase!
> >>>> Internet startups which sell a button on internet, they have Dev and QA
> >>>> team 5 times bigger than that!
> >>>> I sense a very gross capacity and resource planning competence issue in
> >>>> here.
> >>>> I kindly ask you, please forward that mail to your higher Managers, on
> >>>> my personal behalf, Thanks.
> >>>>
> >>>> --
> >>>> http://www.fastmail.com - Same, same, but different...
> >>>>
> >>>
> >>
> >
> 

-- 
http://www.fastmail.com - The way an email service should be
