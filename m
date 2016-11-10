From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next V5 3/9] liquidio CN23XX: Mailbox support
Date: Thu, 10 Nov 2016 17:44:50 +0000
Message-ID: <DM3PR07MB21382E9EA153F2C3FE1BC41881B80@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1478733232-15739-4-git-send-email-rvatsavayi@caviumnetworks.com>
 <20161110.121910.154188943242358141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0083.outbound.protection.outlook.com ([104.47.34.83]:23472
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750877AbcKJSAA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 13:00:00 -0500
In-Reply-To: <20161110.121910.154188943242358141.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Will you please let me know if any more changes that you need, I wi=
ll include all those in next version.

If this the only change then please do confirm, so that I can mail you next=
 patch soon with this change.

Regards
Raghu.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, November 10, 2016 9:19 AM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Vatsavayi, Raghu; Chickles, Derek; Burla,
> Satananda; Manlunas, Felix
> Subject: Re: [PATCH net-next V5 3/9] liquidio CN23XX: Mailbox support
>=20
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Wed, 9 Nov 2016 15:13:46 -0800
>=20
> > +		dev_info(&oct->pci_dev->dev,
> > +			 "PF changed VF's MAC address to
> %02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx\n",
> > +			 mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
>=20
> We have a standard mechanism to print network addresses, including MAC
> ones, via the %pXXX format specifier.  In this case you should use "%pM" =
or
> "%pm" depending upon whether you want the address printed with colon
> separators or not.
