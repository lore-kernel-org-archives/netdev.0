From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-17
Date: Sun, 17 Aug 2008 19:23:05 -0500
Message-ID: <48A8C0E9.6030300@lwfinger.net>
References: <20080817185605.GC30679@tuxdriver.com> <20080817.151251.204370966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080817.151251.204370966.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Their commit messages reference SHA IDs but do not give a commit
> header line text reference as well.
> 
>       p54: Fix regression due to commit b19fa1f

John,

This commit message should fix the above patch:
=============

From: Christian Lamparter <chunkeey-S0/GAf8tV78@public.gmane.org>

Commit b19fa1f, entitled "net: Delete NETDEVICES_MULTIQUEUE kconfig
option" breaks p54pci and p54usb.

Additionally, the old logic always tx'ed cts frames (if enabled)
with a short preamble when [rate > 3]. (i.e. with any 802.11g rate).
Of course this isn't that bad, but it's still wrong!

Signed-off-by: Christian Lamparter <chunkeey-S0/GAf8tV78@public.gmane.org>
Acked-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>         [2.6.25.x, 2.6.26.x]
---

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
