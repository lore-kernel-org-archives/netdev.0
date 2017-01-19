From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Thu, 19 Jan 2017 05:24:51 -0800
Message-ID: <1484832291.16328.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
         <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
         <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
         <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <AM4PR0401MB2260F19C276A1329FD2BB8A7FF7E0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@nicira.com>
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34290 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752694AbdASN6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 08:58:55 -0500
Received: by mail-pg0-f65.google.com with SMTP id t6so4269815pgt.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 05:58:51 -0800 (PST)
In-Reply-To: <AM4PR0401MB2260F19C276A1329FD2BB8A7FF7E0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 08:18 +0000, Andy Duan wrote:

> I will double check your fix. Thanks.
> 
> And, if driver is to support highmem,  then we should add tso highmem
> support in net/core/tso.c,  do you think it is necessary ?


Adding TSO highmem support would mean changing net/core/tso.c ABI and
thus changing all net/core/tso.c users.

Looks a lot of work to me.
