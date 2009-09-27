From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Sun, 27 Sep 2009 13:30:30 -0700
Message-ID: <43e72e890909271330p236c5e6bsbf838119fee9acef@mail.gmail.com>
References: <1254076075.6583.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254076075.6583.6.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 27, 2009 at 11:27 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> The point we assign dev->wireless_handlers at is too
> late, we need to do that before netdev_register_kobject()
> gets called, so use the new NETDEV_PRE_INIT notifier.
> The result of adding wireless_handlers too late is the
> disappearance of /sys/class/net/wlan0/wireless which a
> bunch of distro scripts still require.
>
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> ---
> This should fix the regression Hugh reported (of course requires the
> other patch which unfortunately I forgot to CC you, Hugh, I'll send you
> a copy in private).

Are these stable fixes?

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
