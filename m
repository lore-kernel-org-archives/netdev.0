From: Harini Katakam <harini.katakam@xilinx.com>
Subject: RE: Marvell phy errata origins?
Date: Tue, 18 Apr 2017 15:09:46 +0000
Message-ID: <A00F2239C6748D4289A006FCD55C6D126F19023C@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
 <20170418140450.GB13724@lunn.ch>
 <3c16d944-9874-d016-e3f1-68055a22c173@cisco.com>
 <A00F2239C6748D4289A006FCD55C6D126F1901B7@XAP-PVEXMBX01.xlnx.xilinx.com>
 <93efb026-adbf-d341-166b-90e19d9afb55@cisco.com>
 <A00F2239C6748D4289A006FCD55C6D126F190201@XAP-PVEXMBX01.xlnx.xilinx.com>
 <1ab15dcd-196d-415a-c4ef-388a9b885b2f@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>
To: Daniel Walker <danielwa@cisco.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0084.outbound.protection.outlook.com ([104.47.32.84]:35754
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754489AbdDRPJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 11:09:57 -0400
In-Reply-To: <1ab15dcd-196d-415a-c4ef-388a9b885b2f@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

> -----Original Message-----
> From: Daniel Walker [mailto:danielwa@cisco.com]
> Sent: Tuesday, April 18, 2017 8:26 PM
> To: Harini Katakam <harinik@xilinx.com>; Andrew Lunn <andrew@lunn.ch>
> Cc: Florian Fainelli <f.fainelli@gmail.com>; Andy Fleming
> <afleming@freescale.com>; netdev@vger.kernel.org; HEMANT RAMDASI
> <hramdasi@cisco.com>; Julius Hemanth Pitti -X (jpitti - MONTA VISTA
> SOFTWARE INC at Cisco) <jpitti@cisco.com>; harinikatakamlinux@gmail.com
> Subject: Re: Marvell phy errata origins?
>=20
> On 04/18/2017 07:41 AM, Harini Katakam wrote:
> > Hi Daniel,
> >
> >> -----Original Message-----
> >> From: Daniel Walker [mailto:danielwa@cisco.com]
> >> Sent: Tuesday, April 18, 2017 8:05 PM
> >> To: Harini Katakam <harinik@xilinx.com>; Andrew Lunn <andrew@lunn.ch>
> >> Cc: Florian Fainelli <f.fainelli@gmail.com>; Andy Fleming
> >> <afleming@freescale.com>; netdev@vger.kernel.org; HEMANT RAMDASI
> >> <hramdasi@cisco.com>; Julius Hemanth Pitti -X (jpitti - MONTA VISTA
> >> SOFTWARE INC at Cisco) <jpitti@cisco.com>
> >> Subject: Re: Marvell phy errata origins?
> >>
> >> On 04/18/2017 07:31 AM, Harini Katakam wrote:
> >>> Hi Daniel,
> >>>
> >>>> -----Original Message-----
> >>>> From: Daniel Walker [mailto:danielwa@cisco.com]
> >>>> Sent: Tuesday, April 18, 2017 7:48 PM
> >>>> To: Andrew Lunn <andrew@lunn.ch>
> >>>> Cc: Florian Fainelli <f.fainelli@gmail.com>; Andy Fleming
> >>>> <afleming@freescale.com>; Harini Katakam <harinik@xilinx.com>;
> >>>> netdev@vger.kernel.org; HEMANT RAMDASI <hramdasi@cisco.com>;
> Julius
> >>>> Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)
> >>>> <jpitti@cisco.com>
> >>>> Subject: Re: Marvell phy errata origins?
> >>>>
> >>>> On 04/18/2017 07:04 AM, Andrew Lunn wrote:
> >>>>> On Tue, Apr 18, 2017 at 06:16:33AM -0700, Daniel Walker wrote:
> >>> <snip>
> >>>>>> In Harini's commit
> >>>>>> message for ,
> >>>>>>
> >>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.gi
> >>>>>> t/ co mmit/drivers/net/phy/marvell.c?id=3D3ec0a0f10ceb
> >>>>>>
> >>>>>> "This function has a sequence accessing Page 5 and Register 31,
> >>>>>> both of which are not defined or reserved for this PHY"
> >>>>>>
> >>>>>> For the 88E1112 we see that these are "Factory Test Modes" which
> >>>>>> the contents of are not documented. They aren't really "not
> >>>>>> defied", and aren't really "reserved" .. Marvell support claims
> >>>>>> they don't support these drivers, and Freescale seems to be
> >>>>>> adding these drivers, and the line we are looking at.
> >>>>>>
> >>>>>> We had some issues with our PHY which were corrected with the
> >>>>>> same patch Harini used but modified for the M88E1112. We're
> >>>>>> trying to get to the bottom of where this code came from and what
> >>>>>> it was suppose to be doing.
> >>>>> I tried to find this errata fix in the Marvell reference code. And
> >>>>> failed to find it. But it is "Vendor Crap" code, hard to find
> >>>>> anything in it.
> >>>>>
> >>>>> My guess is, this errata just applies to one model of PHY, maybe
> >>>>> even one revision of one model of a PHY. The hard bit is figuring
> >>>>> out what actually needs it. Do you have access to Marvell datasheet=
s?
> >>> I have access to the datasheets for 88E1111, 88E1112 and 88E1116
> >>> (and another family 151x) - None of them have these register details
> >>> or the errata
> >> documented.
> >>
> >> http://www.dexsilicium.com/Marvell_88E1112.pd
> >>
> >>
> >> Is this the same datasheet ? In this one on page 81 there is page 5
> >> register 31 is "Factory Test Modes" , do you not have that?
> > Yes, it is the same datasheet. That is what I meant - it just says
> > factory test modes But there is no register description.
>=20
> I would call that undocumented. I suspect there are things inside the "Fa=
ctory
> Test Modes" which could be helpful to fix errata. Things which Marvell mi=
ght not
> want to document universally.

OK, agreed.

>=20
> Can you describe what sort of issue you found which was the motivation fo=
r
> your patch ? Or did you remove the code because you did not know what it =
was
> used for?
>=20

I added this patch for 88E1111 because that datasheet does not even have
Page 5 Reg 31 as "Factory Test mode" - it is reserved space.
Any access to that register failed. Since this register was clearly not par=
t of
88E1111 PHY and irrelevant, I removed that code.

Regards,
Harini
