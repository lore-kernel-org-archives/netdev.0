From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Mon, 30 Jan 2017 22:53:13 -0800
Message-ID: <CAM_iQpWmygXWcda825XY0LsaYQ6KbG9cwsNYpTKbq4T0_2UwnQ@mail.gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com> <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
 <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com> <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Elad Raz <e@eladraz.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35883 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdAaGxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 01:53:35 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so10488553wmd.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 22:53:34 -0800 (PST)
In-Reply-To: <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 10:47 PM, Elluru, Krishna Mohan
<elluru.kri.mohan@hpe.com> wrote:
> HI Cong,
>         Have you posted any patch for the same? I am looking for single netlink socket to handle multiple network namespace events using NETLINK_LISTEN_ALL_NSID. I don't see detection of new namespaces by this socket yet and causing updates to be missed.

The patch in $subject was reposted by Paul after fixing the audit part:

commit fba143c66abb81307a450679f38ab953fe96a413
Author: Paul Moore <paul@paul-moore.com>
Date:   Tue Nov 29 16:57:48 2016 -0500

    netns: avoid disabling irq for netns id

Which version of kernel are you testing? Does it have this commit?

Thanks.
