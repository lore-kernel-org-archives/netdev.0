From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against	802.11b
 drivers
Date: Mon, 15 May 2006 15:35:33 +0200
Message-ID: <20060515153533.11491649@griffin.suse.cz>
References: <200605042232.35446.flamingice@sourmilk.net>
	<200605101331.39960.flamingice@sourmilk.net>
	<20060512124703.563dacd6@griffin.suse.cz>
	<200605121635.27959.flamingice@sourmilk.net>
	<20060515133725.3df090af@griffin.suse.cz>
	<1147694684.29795.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50880 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964896AbWEONff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 09:35:35 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1147694684.29795.30.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[removed some people from Cc: list as this is probably not much
interesting for them]

On Mon, 15 May 2006 14:04:44 +0200, Johannes Berg wrote:
> On Mon, 2006-05-15 at 13:37 +0200, Jiri Benc wrote:
> > bcm43xx does that. If I understand it correctly, bcm43xx driver doesn't
> > know allowed modes until it loads firmware. And the firmware is not
> > loaded until the device is opened (they probably have a reason for
> > this). 
> 
> No, that's not right, the firmware has nothing to do with it. At least
> not that we know of, so we treat it as all doing the same :)

Hm, so your calls to ieee80211_update_hw are probably unnecessary.
Anyway, I'm still inclined towards not masking hw_modes by
valid_hw_modes.

 Jiri

-- 
Jiri Benc
SUSE Labs
