From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 13:24:33 -0600
Message-ID: <4B784DF1.200@lwfinger.net>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net> <4B784498.8030509@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Backlund <tmb-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B784498.8030509-4qZELD6Fgxhg9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/14/2010 12:44 PM, Thomas Backlund wrote:
> 
> Nice solution.
> 
> What about making it autodetected ?
> Or is it only a "last resort" with the hopes of getting the issue fixed?

When we detect the problem, we are too far past the initialization to switch
from DMA to PIO.

We certainly hope to fix the issue. We do know that the failure occurs when b43
is loaded after a cold boot, but if one warm boots after using wl, then it works
OK. There is some kind of initialization problem that only shows on Atom and
some Intel Core Duo CPUs.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
