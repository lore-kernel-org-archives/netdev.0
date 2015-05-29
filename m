From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Thu, 28 May 2015 19:36:42 -0700
Message-ID: <5567D0BA.5020409@gmail.com>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org> <1432863742-18427-4-git-send-email-mathieu@codeaurora.org> <5567C7B6.5060905@gmail.com> <20150529022329.GH11260@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150529022329.GH11260-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 05/28/15 19:23, Andrew Lunn a =C3=A9crit :
> On Thu, May 28, 2015 at 06:58:14PM -0700, Florian Fainelli wrote:
>> Le 05/28/15 18:42, Mathieu Olivari a =C3=A9crit :
>>> All switch registers can now be dumped using regmap/debugfs.
>>>
>>> \# cat /sys/kernel/debug/regmap/<mdiobus>/registers
>>> 0000: 00001302
>>> 0004: ...
>>> ...
>>
>> ethtool has a register dump command, which should already be support=
ed
>> by the current code in net/dsa/slave.c, is there a particular reason=
 why
>> you use debugfs here instead?
>=20
> Hi Florian
>=20
> ethtool -d allows you to dump the registers for a port which has a
> slave device. It is sometimes useful to dump the cpu ports registers,
> or DSA ports, i.e. inter switch ports. Marvell devices also have two
> sets of global registers, not specific to any port.
>=20
> For my debugging, i have code which allows you to read the registers
> via debugfs.

=46air enough, are there other global "things" besides counters that co=
uld
deserve adding maybe some sort of global/master net_device to help quer=
y
switch-wide information?
--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
