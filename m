From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Tue, 1 Nov 2016 15:17:43 -0700
Message-ID: <CAPWQB7HtmX7+v37q9rH_3PD+QfSVg_uRiP_=5ZoKnwsF8gpyKg@mail.gmail.com>
References: <20161031183917.9938-1-joe@ovn.org> <66c782de-b2b0-1579-fbb0-634e05e6e511@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com, ast@fb.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:44684 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752557AbcKAWSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 18:18:09 -0400
Received: from mfilter25-d.gandi.net (mfilter25-d.gandi.net [217.70.178.153])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id D33D4FB89F
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 23:18:06 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter25-d.gandi.net (mfilter25-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id kqtSb765h7Xv for <netdev@vger.kernel.org>;
        Tue,  1 Nov 2016 23:18:05 +0100 (CET)
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 69EA2FB8B8
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 23:18:05 +0100 (CET)
Received: by mail-oi0-f48.google.com with SMTP id 128so121685643oih.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 15:18:05 -0700 (PDT)
In-Reply-To: <66c782de-b2b0-1579-fbb0-634e05e6e511@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 13:51, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 10/31/16 12:39 PM, Joe Stringer wrote:
>> Update tools/lib/bpf to provide more functionality and improve interoperation
>> with other tools that generate and use eBPF code.
>>
>> The kernel uapi headers are a bit newer than the version in the tools/
>> directory; synchronize those.
>>
>> samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
>> tools/lib/bpf/bpf* with these functions to bring them into parity.
>>
>> tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
>> map definition to be the same as in tc so the ELFs may be interchangeable
>> (at least for now; I don't have a long-term plan in mind to ensure this always
>> works).
>
> can samples/bpf be converted to use tools/lib/bpf/libbpf.a?

I have a few other patches sitting around that need this series,
including an attempt at this.
