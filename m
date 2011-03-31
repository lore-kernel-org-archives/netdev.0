From: wu zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Fri, 1 Apr 2011 00:03:09 +0800
Message-ID: <AANLkTin48KZ0wc6SiB+E3VOkVAZ5-Xj9WdhstsgEO14z@mail.gmail.com>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>
	<4D8E5BA3.1090909@users.sourceforge.net>
	<AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
	<4D8E8B1E.3030709@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roman Mamedov <rm-pzoh41kZ4TQvJsYlp49lxw@public.gmane.org>
To: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D8E8B1E.3030709-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2011 at 8:55 AM, Hin-Tak Leung
<htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> wrote:
[...]
>
> Hmm, I seem to have the impression that there is code somewhere for
> switching a singular LED's behavior of the driver between one or the other,
> by echo'ing into sysfs or some other trickery? Or would that be a desired
> approach if that's not done at the moment?

Do you mean the interface: /sys/class/rfkill/rfkill0/state? or
something like /sys/class/leds/...::/brightness?

Seems the LED behavior can be triggered automatically by the rfkill
input event with the kernel config option(MAC80211_LEDS, RFKILL_LEDS),
so, echo'ing to such interface may be not a good idea ;-)

Best Regards,
Wu Zhangjin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
