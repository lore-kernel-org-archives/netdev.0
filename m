From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Mon, 31 Jul 2006 16:31:19 -0400
Message-ID: <20060731203113.GG10138@tuxdriver.com>
References: <200607270037.22384.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:12298 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030190AbWGaUbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 16:31:35 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200607270037.22384.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2006 at 12:37:14AM -0700, Michael Wu wrote:
> Alright, I've replaced all + lines with spaces with tabs.
> 
> I also fixed one long line. The rest of them are nearly impossible to shorten 
> well. The "(fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA" style is 
> really killing us (unless you want to break after ==, which is rather bad). I 
> think we should switch back to a macro for that.
> 
> I would prefer if we could get this merged soon and put in that line 
> shortening macro later (or whatever solution that's best), but it's your 
> call.

Michael,

As usual I'll depend on Jiri to merge d80211 stack patches, then
send me a pull request.  If I apply your "Switch drivers to d80211"
series now, that will undoutedly cause a breakage when Jiri asks me
to pull this later.

I presume that at least parts of those patches will still be necessary
or desirable after the d80211 symbol rename gets merged.  Are you
preparing a new patch series for when that happens?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
