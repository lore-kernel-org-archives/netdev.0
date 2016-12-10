From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next 1/8] lib bpf: Add support for BPF_PROG_ATTACH
 and BPF_PROG_DETACH
Date: Sat, 10 Dec 2016 15:15:33 -0700
Message-ID: <93dbc1b0-a76e-4375-0a52-6aa5b4a78c7e@cumulusnetworks.com>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com>
 <1481401934-4026-2-git-send-email-dsa@cumulusnetworks.com>
 <584C70C0.8040506@iogearbox.net> <584C71F0.3000203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35650 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752300AbcLJWPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 17:15:39 -0500
Received: by mail-pf0-f170.google.com with SMTP id i88so7657067pfk.2
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 14:15:39 -0800 (PST)
In-Reply-To: <584C71F0.3000203@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/16 2:21 PM, Daniel Borkmann wrote:
>>
>> Please name it bpf_prog_create() then, it would be consistent to
>> bpf_map_create() and shorter as well.
> 
> Sorry, lack of coffee, scratch that.
> 
> Can't the current bpf_prog_attach() stay as is, and you name the above new
> functions bpf_prog_attach_fd() and bpf_prog_detach_fd()? I think that would
> be better.

ok. no concerns about consistency with libbpf in the kernel repo?

Seems like making iproute2 and the kernel version the same will allow samples and code to move between them much easier.
