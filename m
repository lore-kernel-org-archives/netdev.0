From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Sat, 15 Dec 2012 00:24:37 +0800
Message-ID: <CACVXFVNc8jDm8G9ehEYuAC+OprkJ1VsSc91m0Qd15yxymen1hQ@mail.gmail.com>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
	<CACVXFVNf1EWfnQmDBDoF991cqJOb8g_Ws+tuyBJdE34rbO6GSw@mail.gmail.com>
	<CAKh2mn7C3r_bvKAv4p3AHco=9JpmewOAJ8JwhtFPw50yDy5cUA@mail.gmail.com>
	<4228102.c0z2lbILKD@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4228102.c0z2lbILKD-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 14, 2012 at 10:22 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
> On second thought, I think that if a driver can do manage_power(), even
> only for a subset of devices, it should implement it. Doctoring the table of methods
> is very, very ugly,

Sorry, why is it very ugly?  netdev_ops/ethtool_ops is still set dynamically
inside bind().

> especially as this not protected by a lock.

Looks lock isn't needed since probe/remove and open/close path
can't be concurrent.


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
