From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Fri, 3 Mar 2017 10:11:32 -0800
Message-ID: <CAM_iQpXLS0jPAOzPe8QreXeqhPadHaOdDP5vRkW6CvLXtpReDw@mail.gmail.com>
References: <20170302103219.74b675c5@xeon-e3> <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
 <1601587594.2278.1488487199506.JavaMail.zimbra@polter.net>
 <4bd4e7b9-5546-2e85-bb08-42e45a13e1f3@6wind.com> <20170303160348.GA1888@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Dan Geist <dan@polter.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong@huawei.com, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35444 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdCCSMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:12:32 -0500
Received: by mail-wr0-f196.google.com with SMTP id u108so10272837wrb.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 10:11:53 -0800 (PST)
In-Reply-To: <20170303160348.GA1888@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 8:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> If that use case exists I believe it is an abuse. Soft devices that are
> by definition in upper-lower relationships with other devices should not
> move to other namespaces. Prevents all kinds of issues. If you need a
> soft device like bridge of bond within a namespace, just create it there.
>

I can't agree. Dan's use case is pretty valid, lower devices are moved
into a netns before enslaving to the bonding device, it is perfect valid.
NETIF_F_NETNS_LOCAL was introduced for loopback which is
created during netns creation, forcing users to create a bond device in
each netns is not friendly.

What issues are you talking about there? Can't we just fix them?
