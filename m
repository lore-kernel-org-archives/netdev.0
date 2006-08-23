From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/21] d80211: pull request
Date: Wed, 23 Aug 2006 21:30:33 +0200
Message-ID: <20060823213033.7eff5eef@griffin.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Kimdon <david.kimdon@devicescape.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Mohamed Abbas <mabbas@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39841 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965128AbWHWTaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:30:35 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm also aware of these patches that need more work:

Johannes Berg:
        d80211:  LED triggers
        add nl80211
        make d80211 use nl80211
        d80211:  rework rate control registration
        d80211:  move out rate control registration code
        
David Kimdon:
        d80211: add ioctl to stop data frame tx
        
Larry Finger:
        Add wireless statics to d80211
        (Add wireless statics to bcm43xx-d80211)
        (Add wireless statistics code to d80211 versions of adm8211 and rt2x00)
        
Mohamed Abbas:
        d80211:  add support for SIOCSIWRATE, SIOCSIWTXPOW and SIOCSIWPOWER
        d80211:  iwlist scan

If a d80211 patch you sent in last three weeks is not listed above or
below (and we didn't agree that we would drop it), please scream.

Thanks,

 Jiri

On Wed, 23 Aug 2006 21:24:08 +0200 (CEST), Jiri Benc wrote:
> Please pull from
> git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master
> to obtain following patches:
> 
> David Kimdon:
>       d80211: allow for large scan results
>       d80211: fix multiple device support
>       d80211: fix interface removal
> 
> Jiri Benc:
>       d80211: remove useless and wrong check for interface type
> 
> Johannes Berg:
>       d80211: relax sysfs permissions
>       d80211: master link
>       d80211: pointers as extended booleans
>       d80211: use kzalloc()
>       d80211: get rid of WME bitfield
>       d80211: get rid of sta_aid in favour of keeping track of TIM
>       d80211: clean up exports
>       d80211: clean up includes
>       d80211: fix some sparse warnings
>       d80211: make lowlevel TX framedump option visible
>       d80211: surface IBSS debug
>       d80211: get rid of MICHAEL_MIC_HWACCEL define
>       d80211: surface powersave debug switch
>       d80211: fix some documentation
> 
> Michael Buesch:
>       d80211: add ieee80211_stop_queues()
> 
> Michael Wu:
>       d80211: switch status codes, reason codes, and EIDs to enums
>       d80211: Group EIDs by standard, add remaining 802.11d EIDs


-- 
Jiri Benc
SUSE Labs
