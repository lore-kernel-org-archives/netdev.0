From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Sat, 4 Mar 2017 10:43:22 +0100
Message-ID: <20170304094321.GA1753@nanopsycho>
References: <20170302103219.74b675c5@xeon-e3>
 <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
 <1601587594.2278.1488487199506.JavaMail.zimbra@polter.net>
 <4bd4e7b9-5546-2e85-bb08-42e45a13e1f3@6wind.com>
 <20170303160348.GA1888@nanopsycho.orion>
 <CAM_iQpXLS0jPAOzPe8QreXeqhPadHaOdDP5vRkW6CvLXtpReDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Dan Geist <dan@polter.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong@huawei.com, Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33607 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdCDJvE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 04:51:04 -0500
Received: by mail-wr0-f194.google.com with SMTP id g10so15858095wrg.0
        for <netdev@vger.kernel.org>; Sat, 04 Mar 2017 01:51:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXLS0jPAOzPe8QreXeqhPadHaOdDP5vRkW6CvLXtpReDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 03, 2017 at 07:11:32PM CET, xiyou.wangcong@gmail.com wrote:
>On Fri, Mar 3, 2017 at 8:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> If that use case exists I believe it is an abuse. Soft devices that are
>> by definition in upper-lower relationships with other devices should not
>> move to other namespaces. Prevents all kinds of issues. If you need a
>> soft device like bridge of bond within a namespace, just create it there.
>>
>
>I can't agree. Dan's use case is pretty valid, lower devices are moved
>into a netns before enslaving to the bonding device, it is perfect valid.

I'm not saying it isn't...


>NETIF_F_NETNS_LOCAL was introduced for loopback which is
>created during netns creation, forcing users to create a bond device in
>each netns is not friendly.
>
>What issues are you talking about there? Can't we just fix them?
