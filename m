From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: linux-next: build failure after merge of the origin tree
Date: Mon, 7 Nov 2011 09:46:31 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075501A1CCA47F@orsmsx508.amr.corp.intel.com>
References: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
 <20111106.205259.1237400984015921904.davem@davemloft.net>
 <20111107134706.3e7fc633f913b5e155153127@canb.auug.org.au>
 <20111106.223619.1348742215191441592.davem@davemloft.net>
 <EAE7BD3E-8965-47A4-B3CA-01686E2602C2@intel.com>
 <43F901BD926A4E43B106BF17856F075501A1CCA399@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_43F901BD926A4E43B106BF17856F075501A1CCA47Forsmsx508amrc_"
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A1CCA399@orsmsx508.amr.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_43F901BD926A4E43B106BF17856F075501A1CCA47Forsmsx508amrc_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Rose, Gregory V
> Sent: Monday, November 07, 2011 8:47 AM
> To: Kirsher, Jeffrey T; David Miller
> Cc: sfr@canb.auug.org.au; torvalds@linux-foundation.org; linux-
> next@vger.kernel.org; linux-kernel@vger.kernel.org; netdev@vger.kernel.or=
g
> Subject: RE: linux-next: build failure after merge of the origin tree
>=20
>=20
>=20
> > -----Original Message-----
> > From: Kirsher, Jeffrey T
> > Sent: Sunday, November 06, 2011 9:30 PM
> > To: David Miller
> > Cc: sfr@canb.auug.org.au; torvalds@linux-foundation.org; linux-
> > next@vger.kernel.org; linux-kernel@vger.kernel.org; Rose, Gregory V;
> > netdev@vger.kernel.org
> > Subject: Re: linux-next: build failure after merge of the origin tree
> >
> >
> >
> > Cheers,
> > Jeff
> >
> > On Nov 6, 2011, at 19:38, "David Miller" <davem@davemloft.net> wrote:
> >
> > > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > > Date: Mon, 7 Nov 2011 13:47:06 +1100
> > >
> > >>> If you just revert the commit in origin from -next, then you will
> get
> > >>> conflicts with you pull the net.git tree in.
> > >>
> > >> I got no conflicts when I merged in the net tree and can see no fix
> for
> > >> this problem in the net tree.  My current head of the net tree is
> > 1a6422f
> > >> "etherh: Add MAINTAINERS entry for etherh".
> > >
> > > Ok, Jeff please take a look at this and send me a fix soon.
> > >
> > > Thanks.
> >
> > Ok Dave, at this point, I am puttying together a patch to revert this
> fix
> > since it appears that more trouble comes with this fix.  I will take a
> > look at it quickly before sending out a patch to fix the issue.
>=20
> My bad...  I fixed a compiler warning that occurred with CONFIG_PCI_IOV
> turned on and didn't realize that my patch would cause an error when
> turning it back off.
>=20
> I'll have it fixed ASAP.
>=20
> - Greg

I have posted a fix for this problem to netdev and attached it to this emai=
l.

Again, my apologies for the mix up.

- Greg


>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--_002_43F901BD926A4E43B106BF17856F075501A1CCA47Forsmsx508amrc_
Content-Type: message/rfc822

Received: from orsmga002.jf.intel.com (10.7.209.21) by
 orsmsx606-1.jf.intel.com (10.22.226.128) with Microsoft SMTP Server id
 8.2.255.0; Mon, 7 Nov 2011 09:44:27 -0800
Received: from orsmga101.jf.intel.com ([10.7.208.22])  by
 orsmga002-1.jf.intel.com with ESMTP; 07 Nov 2011 09:44:27 -0800
Received: from vger.kernel.org ([209.132.180.67])  by mga02.intel.com with
 ESMTP; 07 Nov 2011 09:44:26 -0800
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand	id
 S932719Ab1KGRoU (ORCPT <rfc822;tushar.n.dave@intel.com>	+ 22 others); Mon, 7
 Nov 2011 12:44:20 -0500
Received: from mga03.intel.com ([143.182.124.21]:34247 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP	id S1755812Ab1KGRoU
 (ORCPT <rfc822;netdev@vger.kernel.org>);	Mon, 7 Nov 2011 12:44:20 -0500
Received: from azsmga002.ch.intel.com ([10.2.17.35])  by
 azsmga101.ch.intel.com with ESMTP; 07 Nov 2011 09:44:19 -0800
Received: from gitlad.jf.intel.com ([10.23.23.37])  by AZSMGA002.ch.intel.com
 with ESMTP; 07 Nov 2011 09:44:19 -0800
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])	by
 gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id pA7HiHq8008667;	Mon, 7 Nov
 2011 09:44:17 -0800
From: "Rose, Gregory V" <gregory.v.rose@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: "davem@davemloft.net" <davem@davemloft.net>
Sender: "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
Content-Class: urn:content-classes:message
Date: Mon, 7 Nov 2011 09:44:17 -0800
Subject: [net-ext PATCH] ixgbe: Fix compile for kernel without
 CONFIG_PCI_IOV	defined
Thread-Topic: [net-ext PATCH] ixgbe: Fix compile for kernel without
 CONFIG_PCI_IOV	defined
Thread-Index: AcyddOW473jGvoqIRoi0L2fGYAfLWg==
Message-ID: <20111107174417.8638.87569.stgit@gitlad.jf.intel.com>
X-MS-Exchange-Organization-AuthAs: Anonymous
X-MS-Exchange-Organization-AuthSource: orsmsx606.amr.corp.intel.com
X-MS-Has-Attach: 
X-Auto-Response-Suppress: All
X-MS-TNEF-Correlator: 
x-ironport-av: E=Sophos;i="4.69,471,1315206000";    d="scan'208";a="34125486"
x-extloop1: 1
x-ironport-anti-spam-filtered: true
x-ironport-anti-spam-result: 
 AjACACMYuE7RhLRDkWdsb2JhbABChHqVUI4EgSIiAQEBAQkLCwcUBh+BdAEFAiAEJysGCQIkAiYCAgMuFh4LBRgEh2mlG5IdgTCGZYEWBIgLjBaIcYkc
user-agent: StGIT/0.14.2
list-id: <netdev.vger.kernel.org>
x-mailing-list: netdev@vger.kernel.org
x-sg-badattachmentnoreply: True
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0

Rml4IGNvbXBpbGVyIGVycm9ycyBhbmQgd2FybmluZ3Mgd2l0aCBDT05GSUdfUENJX0lPViBkZWZp
bmVkIGFuZCBub3QNCmRlZmluZWQuDQoNClNpZ25lZC1vZmYtYnk6IEdyZWcgUm9zZSA8Z3JlZ29y
eS52LnJvc2VAaW50ZWwuY29tPg0KLS0tDQoNCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
eGdiZS9peGdiZV9zcmlvdi5jIHwgICAgMiArKw0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2l4Z2JlL2l4Z2JlX3NyaW92LmggfCAgICA0ICsrLS0NCiAyIGZpbGVzIGNoYW5nZWQsIDQgaW5z
ZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0
aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3NyaW92LmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9p
bnRlbC9peGdiZS9peGdiZV9zcmlvdi5jDQppbmRleCBkYjk1NzMxLi4wMGZjZDM5IDEwMDY0NA0K
LS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfc3Jpb3YuYw0KKysr
IGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfc3Jpb3YuYw0KQEAgLTQ0
MiwxMiArNDQyLDE0IEBAIHN0YXRpYyBpbnQgaXhnYmVfc2V0X3ZmX21hY3ZsYW4oc3RydWN0IGl4
Z2JlX2FkYXB0ZXIgKmFkYXB0ZXIsDQoNCiBpbnQgaXhnYmVfY2hlY2tfdmZfYXNzaWdubWVudChz
dHJ1Y3QgaXhnYmVfYWRhcHRlciAqYWRhcHRlcikNCiB7DQorI2lmZGVmIENPTkZJR19QQ0lfSU9W
DQogICAgICAgIGludCBpOw0KICAgICAgICBmb3IgKGkgPSAwOyBpIDwgYWRhcHRlci0+bnVtX3Zm
czsgaSsrKSB7DQogICAgICAgICAgICAgICAgaWYgKGFkYXB0ZXItPnZmaW5mb1tpXS52ZmRldi0+
ZGV2X2ZsYWdzICYNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgUENJX0RFVl9GTEFH
U19BU1NJR05FRCkNCiAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiB0cnVlOw0KICAgICAg
ICB9DQorI2VuZGlmDQogICAgICAgIHJldHVybiBmYWxzZTsNCiB9DQoNCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9peGdiZS9peGdiZV9zcmlvdi5oIGIvZHJpdmVycy9u
ZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfc3Jpb3YuaA0KaW5kZXggNGE1ZDg4OS4uZGYw
NGYxYSAxMDA2NDQNCi0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2Jl
X3NyaW92LmgNCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3Ny
aW92LmgNCkBAIC00MiwxMSArNDIsMTEgQEAgaW50IGl4Z2JlX25kb19zZXRfdmZfc3Bvb2ZjaGso
c3RydWN0IG5ldF9kZXZpY2UgKm5ldGRldiwgaW50IHZmLCBib29sIHNldHRpbmcpOw0KIGludCBp
eGdiZV9uZG9fZ2V0X3ZmX2NvbmZpZyhzdHJ1Y3QgbmV0X2RldmljZSAqbmV0ZGV2LA0KICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIGludCB2Ziwgc3RydWN0IGlmbGFfdmZfaW5mbyAqaXZpKTsN
CiB2b2lkIGl4Z2JlX2NoZWNrX3ZmX3JhdGVfbGltaXQoc3RydWN0IGl4Z2JlX2FkYXB0ZXIgKmFk
YXB0ZXIpOw0KLSNpZmRlZiBDT05GSUdfUENJX0lPVg0KIHZvaWQgaXhnYmVfZGlzYWJsZV9zcmlv
dihzdHJ1Y3QgaXhnYmVfYWRhcHRlciAqYWRhcHRlcik7DQoraW50IGl4Z2JlX2NoZWNrX3ZmX2Fz
c2lnbm1lbnQoc3RydWN0IGl4Z2JlX2FkYXB0ZXIgKmFkYXB0ZXIpOw0KKyNpZmRlZiBDT05GSUdf
UENJX0lPVg0KIHZvaWQgaXhnYmVfZW5hYmxlX3NyaW92KHN0cnVjdCBpeGdiZV9hZGFwdGVyICph
ZGFwdGVyLA0KICAgICAgICAgICAgICAgICAgICAgICAgY29uc3Qgc3RydWN0IGl4Z2JlX2luZm8g
KmlpKTsNCi1pbnQgaXhnYmVfY2hlY2tfdmZfYXNzaWdubWVudChzdHJ1Y3QgaXhnYmVfYWRhcHRl
ciAqYWRhcHRlcik7DQogI2VuZGlmDQoNCg0KDQotLQ0KVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlz
IGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVuc3Vic2NyaWJlIG5ldGRldiIgaW4NCnRoZSBib2R5IG9m
IGEgbWVzc2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnDQpNb3JlIG1ham9yZG9tbyBp
bmZvIGF0ICBodHRwOi8vdmdlci5rZXJuZWwub3JnL21ham9yZG9tby1pbmZvLmh0bWwNCg==

--_002_43F901BD926A4E43B106BF17856F075501A1CCA47Forsmsx508amrc_--
