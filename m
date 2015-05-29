From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Fri, 29 May 2015 04:44:25 +0200
Message-ID: <20150529024425.GI11260@lunn.ch>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
 <5567C7B6.5060905@gmail.com>
 <20150529022329.GH11260@lunn.ch>
 <5567D0BA.5020409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5567D0BA.5020409-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Fair enough, are there other global "things" besides counters that could
> deserve adding maybe some sort of global/master net_device to help query
> switch-wide information?

This was discussed a while back. I like the current abstraction, all
interfaces are real interfaces you can send and receive packets
over. This pseudo interface cannot be used for packet transfer, which
seems odd.

Having access to registers for debugging, so debugfs seems like the
best option to me.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
