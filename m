From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Oops with HTB on net-next
Date: Wed, 1 Nov 2017 13:17:32 -0700
Message-ID: <CAA93jw4rM-HHqWM6iY+nkRiGp0ObRxKKUrRO4-0v2oXToPfzpA@mail.gmail.com>
References: <CAA93jw6y3-uO2uXJqiWeu0YeKZCuMyXCO9zvoWXBs=Z04-=KbQ@mail.gmail.com>
 <CAM_iQpWm2oKDLj3FDESWU3kyM==kCAbznc8oHhymOGL883W3rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:54162 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755182AbdKAURd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 16:17:33 -0400
Received: by mail-qt0-f196.google.com with SMTP id n61so4201801qte.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 13:17:33 -0700 (PDT)
In-Reply-To: <CAM_iQpWm2oKDLj3FDESWU3kyM==kCAbznc8oHhymOGL883W3rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 1, 2017 at 9:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Oct 31, 2017 at 11:42 PM, Dave Taht <dave.taht@gmail.com> wrote:
>> I am using a fairly complex htb + three tiers of fq_codel and a couple
>> tc filters (it's the sqm-scripts "simple.qos" model). I rebased on
>> net-next head an hour ago, and....
>>
>> [    8.357963] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becomes ready
>> [    9.759942] u32 classifier
>> [    9.759944]     Actions configured
>> [    9.762152] Mirror/redirect action on
>> [    9.859138] BUG: unable to handle kernel NULL pointer dereference
>> at 0000000000000018
>> [    9.859149] IP: tcf_block_put+0xf/0x50
>
> Do you have this fix?
>
> commit 822e86d997e4d8f942818ea6ac1711f59a66ebef
> Author: Cong Wang <xiyou.wangcong@gmail.com>
> Date:   Mon Oct 30 11:10:09 2017 -0700
>
>     net_sched: remove tcf_block_put_deferred()

No.

That is not in net-next, and the "net" version of that one patch does
not apply to net-next. The relevant thread says "... another fun merge
into net-next".

Please let me know when the fun is done, and I'll retest.

--=20

Dave T=C3=A4ht
CEO, TekLibre, LLC
http://www.teklibre.com
Tel: 1-669-226-2619
