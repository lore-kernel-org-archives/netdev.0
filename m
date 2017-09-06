From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 rfc 8/8] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 06 Sep 2017 09:09:03 -0700
Message-ID: <0D9EF30F-ED95-486E-91B0-E18D5E8689FE@gmail.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <1504654510-31004-9-git-send-email-andrew@lunn.ch> <87d17351gn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170906150825.GB15315@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        nikolay@cumulusnetworks.com
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34914 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754249AbdIFQJJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 12:09:09 -0400
Received: by mail-oi0-f46.google.com with SMTP id n18so44223882oig.2
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 09:09:09 -0700 (PDT)
In-Reply-To: <20170906150825.GB15315@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 6, 2017 8:08:25 AM PDT, Andrew Lunn <andrew@lunn=2Ech> wrote:
>> > Use the MAC address of the master interface as the parent ID=2E This
>is
>> > the same for all switches in a cluster, and should be unique if
>there
>> > are multiple clusters=2E
>>=20
>> That is not correct=2E Support for multiple CPU ports is coming and in
>> this case, you can have two CPU host interfaces wired to two switch
>> ports of the same tree=2E So two different master MAC addresses=2E
>
>Yes, you are correct=2E I will change this=2E

A switch cluster should be tied to the same dsa_switch_tree though, can we=
 use dst->tree as an unique identifier?

--=20
Florian
