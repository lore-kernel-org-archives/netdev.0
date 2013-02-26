From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC/RFT 00/27] Updates for the rtlwifi family of drivers
Date: Mon, 25 Feb 2013 19:26:53 -0800
Message-ID: <1361849213.2023.9.camel@joe-AO722>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1361845357.2023.7.camel@joe-AO722> <512C264A.3000104@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jcheung-IBi9RG/b67k@public.gmane.org, machen-IBi9RG/b67k@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <512C264A.3000104-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-25 at 21:04 -0600, Larry Finger wrote:
> On 02/25/2013 08:22 PM, Joe Perches wrote:
> > On Mon, 2013-02-25 at 18:13 -0600, Larry Finger wrote:
> >> This set of patches upgrades drivers rtlwifi, rtl8192c, rtl8192ce, rtl8192se,
> >> and rtl8723ae to the state of the vendor driver issued on 2013.02.07. In
> >> addition, a new driver for the RTL8188EE chip is added to the kernel.
> >>
> >> Note: These patches do not upgrade rtl8192de. Those changes will be sent
> >> later.
> >
> > rtl8188e isn't very kernel stylish.
> > Looking at it briefly, in fact it's kind of ugly.
> >
> > Could/should it go into staging?
> 
> It is uglier than I had hoped. I was not quite ready to push it yet, but I got 
> some pressure from outside, non-Realtek, sources that a kernel version was 
> needed. They will, in fact, start their integration from the RFC/RFT version.
> 
> The main problem with having it in staging is that we will either have to 
> include headers from drivers/net/wireless/rtlwifi/, or duplicate them in the 
> drivers/staging/rtl8188ee/ directory where keeping them compatible will be a 
> hassle. Neither solution sounds optimum to me.

Perhaps adding a CFLAGS -I include path to a staging Makefile
would work instead.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
