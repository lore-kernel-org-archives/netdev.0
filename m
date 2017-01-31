From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Tue, 31 Jan 2017 09:24:49 +0100
Message-ID: <812a41b1-382c-af18-a0a7-ff4fbc2a96a6@6wind.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
 <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
 <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com>
 <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, Elad Raz <e@eladraz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37474 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdAaIbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 03:31:01 -0500
Received: by mail-wm0-f48.google.com with SMTP id v77so82300374wmv.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 00:31:00 -0800 (PST)
In-Reply-To: <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/01/2017 à 07:47, Elluru, Krishna Mohan a écrit :
> HI Cong,
> 	Have you posted any patch for the same? I am looking for single netlink socket to handle multiple network namespace events using NETLINK_LISTEN_ALL_NSID. I don't see detection of new namespaces by this socket yet and causing updates to be missed.
New namespaces are not automatically detected. You have to assign them a nsid
(e.g. ip netns set).
NETLINK_LISTEN_ALL_NSID enables notifications only for peer netns that have a
nsid assign in the netns where the socket has been opened.


Regards,
Nicolas
