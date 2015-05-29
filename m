From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support\
Date: Fri, 29 May 2015 22:01:22 +0200
Message-ID: <20150529200122.GB22739@lunn.ch>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <20150529020001.GF11260@lunn.ch>
 <20150529184951.GA2458@codeaurora.org>
 <20150529185953.GF19580@lunn.ch>
 <5568C4D4.7010701@gmail.com>
 <20150529195955.GA2884@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150529195955.GA2884-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > What it requires is that for each user port, you can configure what
> > > cpu port it should use. Marvell devices have this ability, and at a
> > > first look, it seems like SF2 does as well, but i will leave Florian
> > > to answer definitively.
> > 
> > That's right, such configuration happens by using VLAN_CTL in the
> > context of SF2, by default only Port <N> and CPU can talk to each other.
> > Bridging ports involving putting them in the same domain, e.g: updating
> > the VLAN_CTL bitmask to include all bridge members.
> 
> Similar here. That would work for ar8xxx too.

Great.

I posted the patches. Comments welcome and lets try to make them work
for all device types, if they don't already.

    Andre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
