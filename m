From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Sat, 11 Feb 2017 13:33:31 +0000
Message-ID: <BL2PR07MB2306B8E60E4862D7939586378D470@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486751311-42019-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0053.outbound.protection.outlook.com ([104.47.32.53]:8287
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932086AbdBKNdf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Feb 2017 08:33:35 -0500
In-Reply-To: <1486751311-42019-1-git-send-email-vidya@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/**
> + * struct ethtool_fecparam - Ethernet forward error correction(fec)
> +parameters
> + * @cmd: Command number =3D %ETHTOOL_GFECPARAM or
> %ETHTOOL_SFECPARAM
> + * @active_fec: FEC mode which is active on porte
> + * @fec: Bitmask of supported/configured FEC modes
> + * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
> + *
> + * Drivers should reject a non-zero setting of @autoneg when
> + * autoneogotiation is disabled (or not supported) for the link.
> + *
> + */

Why request this from drivers?
Can't you reject such configuration requests in the ethtool-core?
