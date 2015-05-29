From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Fri, 29 May 2015 04:23:29 +0200
Message-ID: <20150529022329.GH11260@lunn.ch>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
 <5567C7B6.5060905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
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
In-Reply-To: <5567C7B6.5060905-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 28, 2015 at 06:58:14PM -0700, Florian Fainelli wrote:
> Le 05/28/15 18:42, Mathieu Olivari a =E9crit :
> > All switch registers can now be dumped using regmap/debugfs.
> >=20
> > \# cat /sys/kernel/debug/regmap/<mdiobus>/registers
> > 0000: 00001302
> > 0004: ...
> > ...
>=20
> ethtool has a register dump command, which should already be supporte=
d
> by the current code in net/dsa/slave.c, is there a particular reason =
why
> you use debugfs here instead?

Hi Florian

ethtool -d allows you to dump the registers for a port which has a
slave device. It is sometimes useful to dump the cpu ports registers,
or DSA ports, i.e. inter switch ports. Marvell devices also have two
sets of global registers, not specific to any port.

=46or my debugging, i have code which allows you to read the registers
via debugfs.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
