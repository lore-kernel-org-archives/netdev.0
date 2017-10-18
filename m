From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net/sched: cls_flower: Set egress_dev mark when
 calling into the HW driver
Date: Wed, 18 Oct 2017 10:14:48 +0300
Message-ID: <CAJ3xEMjWCL3kSvfenCaLYnbvmGfyS2-zig7MhVMa1+oUMCLpbA@mail.gmail.com>
References: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com> <1a523077-3c05-ba97-8a65-1967765b8d5a@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:54733 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762063AbdJRHOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:14:49 -0400
Received: by mail-oi0-f44.google.com with SMTP id a132so7308938oih.11
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 00:14:49 -0700 (PDT)
In-Reply-To: <1a523077-3c05-ba97-8a65-1967765b8d5a@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 2:29 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
> On 10/16/2017 12:19 PM, Or Gerlitz wrote:
>
>> Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress
>
>
>    At least 12 digits are needed.

Also on such a spot (e.g not on the Fixes line)?

>
>> Hardware device') made sure (when fl_hw_replace_filter is called) to put
>> the egress_dev mark on persisent structure instance. Hence, following
>> calls

>    Persistent.

right


>> into the HW driver for stats and deletion will note it and act
>> accordingly.

>> With commit de4784ca030f this property is lost and hence when called,
>> the HW driver failes to operate (stats, delete) on the offloaded flow.

>    Fails.

correct

This is applied, will take more care next time
