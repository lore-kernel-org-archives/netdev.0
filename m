From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Tue, 1 Nov 2016 14:51:41 -0600
Message-ID: <66c782de-b2b0-1579-fbb0-634e05e6e511@cumulusnetworks.com>
References: <20161031183917.9938-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, ast@fb.com
To: Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36406 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcKAUvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:51:44 -0400
Received: by mail-pf0-f179.google.com with SMTP id 189so47403137pfz.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 13:51:43 -0700 (PDT)
In-Reply-To: <20161031183917.9938-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 12:39 PM, Joe Stringer wrote:
> Update tools/lib/bpf to provide more functionality and improve interoperation
> with other tools that generate and use eBPF code.
> 
> The kernel uapi headers are a bit newer than the version in the tools/
> directory; synchronize those.
> 
> samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
> tools/lib/bpf/bpf* with these functions to bring them into parity.
> 
> tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
> map definition to be the same as in tc so the ELFs may be interchangeable
> (at least for now; I don't have a long-term plan in mind to ensure this always
> works).

can samples/bpf be converted to use tools/lib/bpf/libbpf.a? 
