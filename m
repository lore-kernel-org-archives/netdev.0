From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [ethtool PATCH v4 0/4]  Add support for QSFP+/QSFP28 Diagnostics
 and 25G/50G/100G      port speeds
Date: Wed, 24 Aug 2016 04:29:22 +0000
Message-ID: <SN2PR11MB009470F680A2B7697167965097EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
References: <1471959033-1053-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "decot@googlers.com" <decot@googlers.com>,
        "bkenward@solarflare.com" <bkenward@solarflare.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>,
        "ben@decadent.org.uk" <ben@decadent.org.uk>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0105.outbound.protection.outlook.com ([104.47.38.105]:61618
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750980AbcHXEa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 00:30:26 -0400
In-Reply-To: <1471959033-1053-1-git-send-email-vidya@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch series provides following support
> a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
>    Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
>    and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
> b) Support for diagnostics information for QSFP Plus/QSFP28 modules
>    based on SFF-8436/SFF-8636
> c) Supporting 25G/50G/100G speeds in supported/advertising fields
> d) Tested across various QSFP+/QSFP28 Copper/Optical modules
>=20
> Standards for QSFP+/QSFP28
> a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
> b) SFF-8024 Rev 4.0 dated May 31, 2016
>=20
> v4:
>   Sync ethtool-copy.h to kernel commit
> 89da45b8b5b2187734a11038b8593714f964ffd1
>   which includes support for 50G base SR2

What about the man-page?
