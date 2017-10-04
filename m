From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] openvswitch: Add erspan tunnel support.
Date: Wed, 4 Oct 2017 16:02:44 -0700
Message-ID: <CALDO+SZRvMm3A8H5iyZnRpc_JfL=dHnyWuhuAB0AudmkCdP86A@mail.gmail.com>
References: <1507118559-13774-1-git-send-email-u9012063@gmail.com> <CAOrHB_DNkfnUty=QzO5d6SAyscLXBP-teE_j0RvDaJiMHqRaaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:56816 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJDXDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 19:03:25 -0400
Received: by mail-it0-f49.google.com with SMTP id g18so17638282itg.5
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 16:03:24 -0700 (PDT)
In-Reply-To: <CAOrHB_DNkfnUty=QzO5d6SAyscLXBP-teE_j0RvDaJiMHqRaaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 4, 2017 at 2:31 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Wed, Oct 4, 2017 at 5:02 AM, William Tu <u9012063@gmail.com> wrote:
>> Add type II erspan vport implementation.  Since erspan protocol is
>> on top of the GRE header, the implementation is extended from the
>> existing gre implementation.
>>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Cc: Pravin B Shelar <pshelar@ovn.org>
>
> Why are you adding ERSPAN support to compat code. Isn't this supported
> over OVS netlink-rtnl (dpif-netlink-rtnl)?

You're right. I will remove it and submit v2. Thanks for the review.

William
