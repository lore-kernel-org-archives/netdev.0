From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 9 Jun 2005 15:12:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506091510560.16917@ladlxr>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408><20050607.132159.35660612.davem@davemloft.net><Pine.LNX.4.62.0506071852290.31708@ladlxr><20050607.204339.21591152.davem@davemloft.net><1118237775.6382.34.camel@localhost.localdomain><Pine.LNX.4.62.0506091406590.10396@ladlxr>
 <20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-601160196-1118355129=:16917"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jamal <hadi@cyberus.ca>,
        "David S. Miller" <davem@davemloft.net>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050609150546.61b0fee7@unknown-215.office.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-601160196-1118355129=:16917
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j59MGiXq021152

On Thu, 9 Jun 2005, Stephen Hemminger wrote:
> > 313667=A0=A0=A0 4.7884=A0 vmlinux=A0=A0=A0=A0=A0=A0=A0=A0=A0 csum_par=
tial
> > 218870=A0=A0=A0 3.3413=A0 vmlinux=A0=A0=A0=A0=A0=A0=A0=A0=A0 _spin_lo=
ck
> > 214302=A0=A0=A0 3.2715=A0 vmlinux=A0=A0=A0=A0=A0=A0=A0=A0=A0 __copy_u=
ser_intel
> > 193662=A0=A0=A0 2.9564=A0 vmlinux=A0=A0=A0=A0=A0=A0=A0=A0=A0 skb_rele=
ase_data
> > 177755=A0=A0=A0 2.7136=A0 vmlinux=A0=A0=A0=A0=A0=A0=A0=A0=A0 ipt_do_t=
able
>=20
> You are probably benchmarking iptables/netfilter! How many rules do you
> have?

I saw that... somehow iptables got compiled into kernel statically.  no=20
rules are active or installed  iptables -L -n shows nothing in any chain.

Jesse
--8323328-601160196-1118355129=:16917--
