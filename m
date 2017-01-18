From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Wed, 18 Jan 2017 11:51:17 -0800
Message-ID: <1484769077.13165.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
         <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
         <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
         <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAOrHB_A-oJid6RTeQB_xy0GDKsJjvEDwdTepMXN336qSi5h8AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>,
        Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@nicira.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36679 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752324AbdARUUR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 15:20:17 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so2154795pgf.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 12:20:16 -0800 (PST)
In-Reply-To: <CAOrHB_A-oJid6RTeQB_xy0GDKsJjvEDwdTepMXN336qSi5h8AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-18 at 10:18 -0800, Pravin Shelar wrote:
\
> Right, this high mem check should be decoupled from csum check.

I must say I am surprised nobody hit this problem before today.

linux-3.10 is more than 3 years old.
