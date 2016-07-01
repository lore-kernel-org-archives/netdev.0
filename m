From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCHv2 net-next 1/3] net: Add provision to specify pf number
 while assigning VF mac
Date: Fri, 1 Jul 2016 08:40:56 +0530
Message-ID: <20160701031055.GA29804@hari-Latitude-E5550>
References: <1467300884-32340-1-git-send-email-hariprasad@chelsio.com>
 <1467300884-32340-2-git-send-email-hariprasad@chelsio.com>
 <CO2PR11MB0088BB6334851B5B51E5851497240@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:61673 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751969AbcGADNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 23:13:17 -0400
Content-Disposition: inline
In-Reply-To: <CO2PR11MB0088BB6334851B5B51E5851497240@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 19:04:16 +0000, Yuval Mintz wrote:
> > Chelsio T4/T5 cards have SR-IOV Capabilities on Physical Functions
> > 0..3 and the administrative Driver(cxgb4) attaches to Physical Func=
tion 4.
> > Each of the Physical Functions 0..3 can support up to 16 Virtual
> > Functions. With the current Linux APIs, a 2-Port card would only be
> > able to use the Virtual Functions on Physical Functions 0..1 and no=
t
> > allow the Virtual Functions on Physical Functions 2..3 to be used s=
ince
> > there are no Ports 2..3 on a 2-Port card.
> >
> > Also the current ip commands takes netdev as one of the argument, a=
nd
> > it assumes a 1-to-1 mapping of Network Ports, Physical Functions an=
d the
> > SR-IOV Virtual Functions of those Physical Functions. But it is not
> > true in our case and won't work for us.
> >=20
> > Added a new argument to specify the PF number associated with the V=
=46, to
> > fix this.
>=20
> I don't get it - what's the exact definition of 'Physical Function'?
> Are we talking PCI functions? Logical partitons? Something else?

Its PCIe physical function. Physical functions (PFs) are full-featured
PCIe functions; virtual functions (VFs) are =E2=80=9Clightweight=E2=80=9D=
 functions that
lack configuration resource.
