From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [RFC PATCH  v2] net: ethtool: add support for forward error
 correction modes
Date: Wed, 15 Feb 2017 17:38:07 +0000
Message-ID: <MWHPR12MB1600C9C8528A929DD0404943C85B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1486727004-11316-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0098.outbound.protection.outlook.com ([104.47.36.98]:42787
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750905AbdBORiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 12:38:09 -0500
In-Reply-To: <1486727004-11316-1-git-send-email-vidya@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Vidya and I have been in communication on how to support Forward Error Co=
rrection Management on Links.  My own thoughts are that we should consider =
using the new Get/Set Link Ksettiongs API because FEC is a low-level Link p=
arameter which is either negotiated at the same time as Link Speed if Auto-=
Negotiation is in use, or must be set identically on both Link Peers is AN =
is not in use.  I'm not convinced that FEC Management should use a separate=
 ethtool/Kernel Driver API ala Pause Frame settings.

  I'm hoping to meet with Vidya and his collaborators at Cumulus Networks i=
n the very near term to hash these issues out.

Casey
