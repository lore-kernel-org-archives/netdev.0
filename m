From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-06-04
Date: Sun, 07 Jun 2009 17:29:43 +0200
Message-ID: <1244388583.23850.87.camel@localhost.localdomain>
References: <20090604152011.GC2839@tuxdriver.com>
	 <20090607.033751.191866033.davem@davemloft.net>
	 <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com>
	 <4A2BD8A5.4040302@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A2BD8A5.4040302-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

> >>>> Hopefully this is (almost?) the last wireless pull request for
> >>>> non-bugfix patches intended for 2.6.31...
> >>>>
> >> (..)
> >>
> >>>> Please let me know if there are problems!
> >>> Pulled into net-next-2.6 and I'll push it back out to kernel.org
> >>> after some build testing.
> >> Hi John,
> >>
> >> after pulling the latest net-next-2.6 i got this warning which is probably
> >> caused by CONFIG_RFKILL=m in my config:
> >>
> >> hartko@vwagwolkf320:~/net-next-2.6$ make oldconfig
> >> scripts/kconfig/conf -o arch/x86/Kconfig
> >> .config:614:warning: symbol value 'm' invalid for RFKILL_INPUT
> > 
> > That functionality is no longer available as a module.  If you need
> > it, then select Y.
> 
> Just some additional nitpicking:
> 
> You should update net/rfkill/Kconfig as it still allows a tristate selection
> for RFKILL and the comment "To compile this driver as a module ..." should be
> removed also.

compiling RFKILL itself as a module is still working perfectly fine. It
is just the RFKILL_INPUT that can't be built as a module anymore. That
part was pointless anyway. And in the future RFKILL_INPUT will go away
and be replaced by a userspace implementation with proper support for
platform specific policies.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
