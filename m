From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2 4/4] ath9k:  Support ethtool getstats api.
Date: Fri, 16 Mar 2012 22:38:55 +0100
Message-ID: <201203162238.55596.chunkeey@googlemail.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com> <1331931427.2504.12.camel@bwh-desktop.uk.solarflarecom.com> <4F63B00A.4050904@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:52976 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756349Ab2CPVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 17:39:00 -0400
In-Reply-To: <4F63B00A.4050904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 March 2012 22:26:34 Ben Greear wrote:
> On 03/16/2012 01:57 PM, Ben Hutchings wrote:
> > On Fri, 2012-03-16 at 20:53 +0000, Ben Hutchings wrote:
> >> On Fri, 2012-03-16 at 12:59 -0700, greearb@candelatech.com wrote:
> >>> From: Ben Greear<greearb@candelatech.com>
> >>>
> >>> This returns many of the values that formerly could
> >>> only be obtained from debugfs.  This should be an
> >>> improvement when trying to access these counters
> >>> programatically.  Currently this support is only
> >>> enabled when DEBUGFS is enabled because otherwise
> >>> these stats are not accumulated.
> >> [...]
> >>
> >> Given that ethtool (unlike debugfs) is itself an unconditional feature,
> >> why not make this unconditional?  Is it expensive to accumulate the
> >> stats?
> >>
> >> Please at least fix the name.
> >                           ^ config option
> >
> 
> The ath9k stats are currently only gathered when debugfs is enabled.
> 
> I could do some patches in the future to allow stats to always
> be gathered regardless of debugfs being enabled, but since
> ath9k is used on small form factor systems, there may be some
> resistance to enabling that all the time.
When we are talking about small form factor.
Did you know that OpenWRT has enabled ath9k's debugfs feature by default?
Even the image for my TL-WR841ND [just a 4MiB flash] has it enabled! 
So I don't that's much of a problem. Even more the debugfs bits are
probably smaller than all those initvals [you know, those for the whole
AR5008/AR91XX/AR92XX/AR93XX/AR94XX gang] they have to carry around.
[Yeah, if you use the same rev-chips on your stuff, you could get
away with just one initval... Think of the savings!]

Regards,
	Chr
