From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Mon, 31 Jul 2017 12:40:19 -0600
Message-ID: <737970c5-5a5a-025a-2c1c-205971b6898e@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com>
 <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
 <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
 <7f404f61-0b9a-b25b-3c15-83395d30641d@gmail.com>
 <CAJieiUgxQ+okYAffbb6dqA-=U9qn1QA7A3-ZJ8=HC=o1bkF3ow@mail.gmail.com>
 <ea0c0319-1b74-da8f-e307-2bf02e674119@gmail.com>
 <CAM_iQpVobEXqE-CWVpQU4b8jnOrzq9EEfszj+SnyqX-RZ+B6Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33960 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdGaSkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 14:40:22 -0400
Received: by mail-pf0-f176.google.com with SMTP id q85so124114171pfq.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 11:40:22 -0700 (PDT)
In-Reply-To: <CAM_iQpVobEXqE-CWVpQU4b8jnOrzq9EEfszj+SnyqX-RZ+B6Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/17 12:37 PM, Cong Wang wrote:
> 
>> So Roopa's fibmatch patches brings consistency between IPv4 and IPv6 at
>> the cost of breaking backwards compatibility for IPv6 when the prohibit
>> or blackhole routes are hit.
>>
> There are already many differences between IPv4 and
> IPv6 behaviors, I don't see why this one is so special
> that we have to make it consistent.

yes, and I have sent a number of patches closing the gap.
