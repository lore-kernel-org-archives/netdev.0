From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH RFC 0/7] phylib MMD accessor cleanups
Date: Tue, 21 Mar 2017 13:09:13 +0000
Message-ID: <20170321130912.GY21222@n2100.armlinux.org.uk>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
 <0b44bbd9-2be9-85cb-1518-4e4ec36927e1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0b44bbd9-2be9-85cb-1518-4e4ec36927e1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 19, 2017 at 03:30:38PM -0700, Florian Fainelli wrote:
> Le 03/19/17 à 03:59, Russell King - ARM Linux a écrit :
> > This series of patches does exactly that - we merge the functionality
> > of the indirect accesses into the clause 45 accessors, and use these
> > exclusively to access MMD registers.  Internally, the new clause
> > independent MMD accessors indirect via the PHY drivers read_mmd/write_mmd
> > methods if present, otherwise fall back to using clause 45 accesses if
> > the PHY is a clause 45 phy, or clause 22 indirect accesses if the PHY
> > is clause 22.
> 
> LGTM:
> 
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks.  When I posted this last time around (19th Jan) I mentioned
about marking the old _indirect() accessors with __deprecated - is
that still something we want to do?

I haven't tested this against net-next yet, so I don't know if there
are any new users of the indirect accessors - going down the deprecated
route would avoid breakage, but means having to submit a patch later to
actually remove them.

How would people want this handled?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
