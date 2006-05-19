From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b drivers
Date: Fri, 19 May 2006 14:06:54 -0400
Message-ID: <20060519180649.GD30177@tuxdriver.com>
References: <200605042232.35446.flamingice@sourmilk.net> <200605121635.27959.flamingice@sourmilk.net> <20060515133725.3df090af@griffin.suse.cz> <200605151319.23246.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:37130 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932453AbWESSHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 14:07:14 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200605151319.23246.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 01:19:23PM -0400, Michael Wu wrote:
> On Monday 15 May 2006 07:37, Jiri Benc wrote:
> > This issue can be easily solved by not masking hw_modes by
> > valid_hw_modes in ieee80211_ioctl_prism2_param and
> > ieee80211_precalc_modes. Just check (hw_modes & valid_hw_modes) instead
> > of hw_modes in ieee80211_sta_scan_timer.
> >
> > And yes, hw_modes is a confusing name. It should be named
> > hw_modes_mask_disabled_by_user or so. Maybe at least some better comment
> > about this in ieee80211_i.h won't be a bad idea.
> >
> Okay, how about this? Instead of adding valid_hw_modes, I added enabled_modes, 
> and replaced all instances of local->hw_modes with local->enabled_modes. 
> local->hw_modes now really means what modes are supported by the hardware.

Are we satisfied w/ this patch?  If so, please repost the patch after
cleaning-up the changelog according to the rules here:

	http://linux.yyz.us/patch-format.html

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
