From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: nsid cannot be allocated for a dead netns
Date: Thu, 17 Nov 2016 08:50:16 -0800
Message-ID: <CAM_iQpW+r3vpQb0=0Bd7xj7DVFUNMh4voGRCyggaMS4u2bOziw@mail.gmail.com>
References: <201611161759.tCk5fdCO%fengguang.wu@intel.com> <1479289775-1715-1-git-send-email-nicolas.dichtel@6wind.com>
 <CAM_iQpXzp54gOyiRu4PUcJhLEB3T+TTEL+JLE2PL+oB31ZuCJw@mail.gmail.com>
 <20161116.231722.2198167385156796830.davem@davemloft.net> <CAM_iQpUGayFoDSQL2w6bOVKG2q=dSDyf1jQ5LvrYuy7V_y_auA@mail.gmail.com>
 <0fb84877-d43d-736a-c5a8-1ca954f90925@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Andrey Wagin <avagin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:36584 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754446AbcKQRQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:16:07 -0500
Received: by mail-it0-f54.google.com with SMTP id l8so150615178iti.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 09:16:06 -0800 (PST)
In-Reply-To: <0fb84877-d43d-736a-c5a8-1ca954f90925@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 12:41 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 17/11/2016 =C3=A0 07:32, Cong Wang a =C3=A9crit :
> [snip]
>> since Nicolas' patch doesn't even compile...
> It's always surprising how agressive you are, really :(
> Can you show me the compilation error of this patch (we are talking about=
 the v2
> patch here)?

Sorry about that, I didn't event look at your v2, because your patch
(no matter v2 or v1) is already wrong to me, the idr_for_each() before
alloc_netid() is clearly a use-after-destroy.

Based on the same reason, my patch is not your v3, we are patching
different places.
