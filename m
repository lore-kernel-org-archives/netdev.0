From: "Guvva, Vijaya" <Vijaya.Guvva@cavium.com>
Subject: RE: [PATCH V2 net-next 1/2] liquidio: switchdev support for LiquidIO
 NIC
Date: Tue, 31 Oct 2017 19:32:01 +0000
Message-ID: <DM3PR07MB215455E6D8BD6A802A8289FBE15E0@DM3PR07MB2154.namprd07.prod.outlook.com>
References: <20171027190833.GA19806@felix-thinkpad.cavium.com>
        <20171027190917.GA19831@felix-thinkpad.cavium.com>
 <20171027164505.4cc0df92@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0079.outbound.protection.outlook.com ([104.47.37.79]:30094
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932625AbdJaTdI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 15:33:08 -0400
In-Reply-To: <20171027164505.4cc0df92@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jakub for reviewing the changes.

> SWITCHDEV_ATTR_ID_PORT_PARENT_ID is generally used to determine
> whether two ports belong to the same switch.  Do you not want to support =
rules
> which redirect packets from one PF (and it's VFs) to the other?
>=20
We would be presenting each PF as a separate switch in switchdev model.
So, will be returning separate switchID for each PF.

> Also if you plug two cards into one system, the above will make you offlo=
ad
> redirect between the cards.  Is that what you want?  Commonly the MAC
> address of the first port or serial number would be used here to make sur=
e IDs
> are unique for each device.
This was done to have static UDEV rules which works on all liquidIO devices=
. We will resubmit patches for using mac address as switchID.

Thanks,
Vijay
