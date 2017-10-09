From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/7] nfp: extend match and action for flower offload
Date: Mon, 9 Oct 2017 08:45:41 -0700
Message-ID: <CALx6S34Akd2Z3TDaEKwG3-1BwSZ79bO4kweuLojw=00cg0t=Nw@mail.gmail.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
 <CALx6S36zb=V3Uv1xxjQi04TaPre7GRyYQ1Wcx_7zd96nSpu3pg@mail.gmail.com> <20171009080545.GB11130@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:49503 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754357AbdJIPpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 11:45:42 -0400
Received: by mail-qk0-f172.google.com with SMTP id s14so10715515qks.6
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 08:45:42 -0700 (PDT)
In-Reply-To: <20171009080545.GB11130@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 9, 2017 at 1:05 AM, Simon Horman <simon.horman@netronome.com> wrote:
> On Fri, Oct 06, 2017 at 08:34:59AM -0700, Tom Herbert wrote:
>> Simon,
>>
>> Maybe a bit off topic, but I had the impression netronome would
>> support BPF so that filters could be programmed for arbitrary
>> protocols and fields. Is that true? If so, what is the relationship
>> between that functionality and these patches?
>
> Hi Tom,
>
> you are correct in thinking that Netronome is supporting BPF offload
> in its nfp driver. That support continues to be enhanced and supported.
>
> This patch-set relates to a different set of functionality, offload of the
> TC flower classifier. At this point there is no relationship between the
> two sets of functionality and they cannot be used at the same time;
> different firmware images are required and the driver initiates itself
> according to the firmware loaded.
>
> In future it may be possible to use both BPF and TC flower offloads at the
> same time but that is not the case at this time.
>
> Does that answer your question?

Yes... A couple of follow up questions. If someone uses tc-bpf would
that be offloaded to nfp? Is there anything that TC flower offloads
can do that the BPF solution can't do?

Thanks,
Tom
