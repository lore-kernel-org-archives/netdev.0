From: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support\
Date: Fri, 29 May 2015 12:59:55 -0700
Message-ID: <20150529195955.GA2884@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <20150529020001.GF11260@lunn.ch>
 <20150529184951.GA2458@codeaurora.org>
 <20150529185953.GF19580@lunn.ch>
 <5568C4D4.7010701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5568C4D4.7010701-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 29, 2015 at 12:58:12PM -0700, Florian Fainelli wrote:
> On 29/05/15 11:59, Andrew Lunn wrote:
> > On Fri, May 29, 2015 at 11:49:54AM -0700, Mathieu Olivari wrote:
> >> On Fri, May 29, 2015 at 04:00:01AM +0200, Andrew Lunn wrote:
> >>> FYI:
> >>>
> >>> I have patches which allow DSA to use two cpu interfaces. Seems to
> >>> work on my DIR665 with a Marvell Switch.
> >>>
> >>> I will post the patches as an RFC.
> >>>
> >>>   Andrew
> >>
> >> Does it require the switch CPU ports to support LAG or is it generic
> >> enough to allow switch partitioning?
> > 
> > When using tags, DSA by default partitions the switch. Each user port
> > is separate from other ports. lan4 will not bridge to lan1 unless you
> > either do it in software, or you implement the
> > .port_join_bridge/.port_leave_bridge/.port_stp_update methods of
> > dsa_switch_driver.
> > 
> > What it requires is that for each user port, you can configure what
> > cpu port it should use. Marvell devices have this ability, and at a
> > first look, it seems like SF2 does as well, but i will leave Florian
> > to answer definitively.
> 
> That's right, such configuration happens by using VLAN_CTL in the
> context of SF2, by default only Port <N> and CPU can talk to each other.
> Bridging ports involving putting them in the same domain, e.g: updating
> the VLAN_CTL bitmask to include all bridge members.

Similar here. That would work for ar8xxx too.

> -- 
> Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
