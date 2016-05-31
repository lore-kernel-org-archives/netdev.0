From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211_hwsim: Add missing check for HWSIM_ATTR_SIGNAL
Date: Tue, 31 May 2016 12:12:07 +0200
Message-ID: <1464689527.3076.9.camel@sipsolutions.net>
References: <1463136108-4434-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463136108-4434-1-git-send-email-martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 12:41 +0200, Martin Willi wrote:
> A wmediumd that does not send this attribute causes a NULL pointer
> dereference, as the attribute is accessed even if it does not exist.
> 
> The attribute was required but never checked ever since userspace
> frame
> forwarding has been introduced. The issue gets more problematic once
> we
> allow wmediumd registration from user namespaces.
> 
Applied, thanks.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
