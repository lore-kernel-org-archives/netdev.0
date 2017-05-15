From: Morgan Yang <morgan.yang1982@gmail.com>
Subject: Re: Advice on user space application integration with tc
Date: Mon, 15 May 2017 13:39:27 -0700
Message-ID: <CAHV_CwbvSbLXy7gfJdTWrrimk+MZP6r+fDZjqc1L8rkUA8p2Xw@mail.gmail.com>
References: <CAHV_CwaAF-tDqEpPT1LL04tqTLE14qqqhxZtsB+d-ndKot8_UQ@mail.gmail.com>
 <CAM_iQpWnxTuHQfXzxQ6Cg5Ec=D7yJQsvw+3WpnzDuDXAUow7fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36810 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759546AbdEOUj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 16:39:28 -0400
Received: by mail-qk0-f195.google.com with SMTP id y128so19460146qka.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 13:39:28 -0700 (PDT)
In-Reply-To: <CAM_iQpWnxTuHQfXzxQ6Cg5Ec=D7yJQsvw+3WpnzDuDXAUow7fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried on both stock CentOS 7.3 and Ubuntu 16.04 and tc-skbmod was
not support (I built tc from the latest versions of iproute2). For
tc-pedit, examples from man tc-pedit such as "pedit ex munge" were not
supported, but "pedit munge offset" is.

On Mon, May 15, 2017 at 1:14 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, May 11, 2017 at 1:45 PM, Morgan Yang <morgan.yang1982@gmail.com> wrote:
>> Hi All:
>>
>> I want to build a solution that leverages the filtering and actions of
>> tc in kernel space, but have the ability to hook  to a userspace
>> application that can additional packet processing (such as payload
>> masking). I'm curious what are the best ways to go about doing that? I
>> have been looking into tc-skbmod and tc-pedit, but as good as they
>> are, they would require newer kernels. I have also tried using tc to
>> mirror filterd packets to a dummy or tap interface, and have the
>> userspace application pick up there, but the performance has been
>> supar. I'm hoping to have a solution that avoids the extra mirroring.
>
>
> act pedit exists for a rather long time, I don't think you need a new
> kernel to use it, unless of course you have a different definition of
> "new kernel". ;)
