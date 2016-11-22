From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [RFC PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Tue, 22 Nov 2016 23:41:34 +0000
Message-ID: <DM5PR12MB1786C97235D728D6087AA933C8B40@DM5PR12MB1786.namprd12.prod.outlook.com>
References: <DM5PR12MB178630AFB893C17362A4C09BC8BB0@DM5PR12MB1786.namprd12.prod.outlook.com>,<DM5PR12MB1786073763933EAE09E36978C8B40@DM5PR12MB1786.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0120.outbound.protection.outlook.com ([104.47.34.120]:22361
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751644AbcKVXzs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 18:55:48 -0500
In-Reply-To: <DM5PR12MB1786073763933EAE09E36978C8B40@DM5PR12MB1786.namprd12.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  And by the way, we currently have two ethtool APIs which pump in an Auto-=
Negotiation indication -- set_link_ksettings() and set_pauseparam().  Now w=
e're talking about adding a third, set_fecparam().  Are all of the calls to=
 these three APIs supposed to agree on the concept of Auto-Negotiations?  I=
.e. what's it mean if set_link_ksettings() gets called with link_ksettings-=
>base.autoneg =3D=3D AUTONEG_ENABLE but set_pauseparam() gets called with e=
pause->autoneg =3D=3D AUTONEG_DISABLE?  And now adding set_fecparam() into =
the system with a similar ability to specify the state of Auto-Negotiation =
is even more confusing.

Casey=
