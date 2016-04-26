From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 1/5] ti: Convert wl1271_<level> logging macros to dev_<level> or pr_<level>
Date: Tue, 26 Apr 2016 12:06:09 +0300
Message-ID: <87d1pczqm6.fsf@kamboji.qca.qualcomm.com>
References: <cover.1457395071.git.joe@perches.com>
	<760b583e96a9a88f06e97150617f791c3726a302.1457395071.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <760b583e96a9a88f06e97150617f791c3726a302.1457395071.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
	(Joe Perches's message of "Mon, 7 Mar 2016 16:19:33 -0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> Use the more common logging mechanism passing wl->dev where
> appropriate.  Remove the macros.  Add argument struct wl1271 *wl to
> some functions to make these logging mechanisms work.
>
> Miscellanea:
>
> o Coalesce formats, add required trailing \n to formats
>   Some formats already had previously incorrect \n uses
> o Realign arguments
> o Correct a couple typos and grammar defects
> o Split a multiple line error message to multiple calls of dev_err
> o Add #define pr_fmt when pr_<level> is used
> o Remove unnecessary/duplicate pr_fmt use from wl1271_debug macro
>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Doesn't apply anymore:

Applying: ti: Convert wl1271_<level> logging macros to dev_<level> or pr_<level>
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging drivers/net/wireless/ti/wlcore/wlcore_i.h
Auto-merging drivers/net/wireless/ti/wlcore/tx.c
Auto-merging drivers/net/wireless/ti/wlcore/scan.c
Auto-merging drivers/net/wireless/ti/wlcore/rx.c
Auto-merging drivers/net/wireless/ti/wlcore/ps.c
Auto-merging drivers/net/wireless/ti/wlcore/main.c
Auto-merging drivers/net/wireless/ti/wlcore/cmd.c
CONFLICT (content): Merge conflict in drivers/net/wireless/ti/wlcore/cmd.c
Auto-merging drivers/net/wireless/ti/wl18xx/tx.c
Auto-merging drivers/net/wireless/ti/wl18xx/scan.c
Auto-merging drivers/net/wireless/ti/wl18xx/main.c
Auto-merging drivers/net/wireless/ti/wl18xx/event.c
Auto-merging drivers/net/wireless/ti/wl18xx/debugfs.c
Auto-merging drivers/net/wireless/ti/wl18xx/cmd.c
Auto-merging drivers/net/wireless/ti/wl12xx/scan.c
Auto-merging drivers/net/wireless/ti/wl12xx/main.c
Failed to merge in the changes.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
