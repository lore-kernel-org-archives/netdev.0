From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 12:41:08 -0800
Message-ID: <1258490468.4447.23.camel@localhost.localdomain>
References: <1258465585.3682.7.camel@johannes.local>
	 <200911171504.54170.mb@bu3sch.de> <1258466868.3682.13.camel@johannes.local>
	 <20091117083741.1b165274@nehalam> <1258476223.21197.0.camel@johannes.local>
	 <20091117090420.0434edc3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091117090420.0434edc3@nehalam>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-17 at 09:04 -0800, Stephen Hemminger wrote:
> On Tue, 17 Nov 2009 17:43:43 +0100
> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> 
> > On Tue, 2009-11-17 at 08:37 -0800, Stephen Hemminger wrote:
> > 
> > > But there are people bridging wireless, and hostap even has a mode for
> > > that. 
> > 
> > But that's the AP side, which this patch doesn't attempt to prevent. It
> > just makes no sense to bridge when connected to an AP or part of an
> > IBSS.
> > 
> 
> Then how does this work now? And will your change break it?
> 
>                              kvm1
>                             /
>      ====> wlan0  --- bridge-- kvm2
>                             \
>                              kvm3

Are you sure 'bridge' isn't NAT-ed to wlan0 like libvirt/etc do by
default?  That's about the only way it can possibly work correctly with
wifi.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
