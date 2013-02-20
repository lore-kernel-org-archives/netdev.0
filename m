From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/1] net: rfkill: Fix sparse warning in
 rfkill-regulator.c
Date: Wed, 20 Feb 2013 11:09:31 +0100
Message-ID: <1361354971.8629.18.camel@jlt4.sipsolutions.net>
References: <1361267868-2316-1-git-send-email-sachin.kamat@linaro.org>
	 (sfid-20130219_110850_873316_C9085702) <1361354928.8629.17.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_110906_640334_BAA70538)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361354928.8629.17.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org> (sfid-20130220_110906_640334_BAA70538)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-20 at 11:08 +0100, Johannes Berg wrote:
> On Tue, 2013-02-19 at 15:27 +0530, Sachin Kamat wrote:
> > 'rfkill_regulator_ops' is used only in this file. Hence make it static.
> > Silences the following warning:
> > net/rfkill/rfkill-regulator.c:54:19: warning:
> > symbol 'rfkill_regulator_ops' was not declared. Should it be static?
> 
> I'll take this, but it isn't going anywhere until the merge window opens
> again.

Err, I mean closes, and we open -next.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
