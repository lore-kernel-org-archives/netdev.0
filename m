From: "Dave Santucci" <dave_santucci@vivato.net>
Subject: RE: [VLAN] VLAN patches
Date: Mon, 30 Sep 2002 08:55:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <D8B86D9BB607124BA1D54EDB7944DB0B140BC4@exchange.mabuhay>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <vlan@Scry.WANfear.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bjorn
	Since the data type for the vlan_id is specified as an "unsigned short",
	The comparison (vlan_id < 0) will always be false due to the range of th=
e data
 	type.

	-ds
=09

-----Original Message-----
From: Andersson Bj=F6rn [mailto:Bjorn.Andersson@ebc.ericsson.se]=20
Sent: Monday, September 30, 2002 1:24 AM
To: netdev@oss.sgi.com
Subject: [VLAN] VLAN patches

Hi,
I hope you are the right receiver of 8021q-patches.
We are running SuSe 8.0, i.e kernel 2.4.18.

- When addding several egress-mappings we get stuck in an eternal
loop if they end up in the same hash-bucket, see vlan_dev.c.path.

- If we try to remove a vlan with VID 0, ifconfig stops working
completly.
We fixed it with vlan.c.patch.


--=20
* Bj=F6rn Andersson                   bjorn.andersson@ebc.ericsson.se *
* Ericsson Enterprise AB            NA/EBC/BEES/DNCC                *
* Nacka Strand                      tel: +46-8-422 3512             *
* 13 189 Stockholm, Sweden          fax: +46-8-422 1010             *
