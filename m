From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 01/15] bpf: BPF support for sock_ops
Date: Fri, 23 Jun 2017 01:19:01 +0200
Message-ID: <594C5065.2010900@iogearbox.net>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-2-brakmo@fb.com> <594C47A1.1080102@iogearbox.net> <B03E3B5A-50E2-4291-B091-23927AF6846F@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48441 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753672AbdFVXTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 19:19:06 -0400
In-Reply-To: <B03E3B5A-50E2-4291-B091-23927AF6846F@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2017 12:58 AM, Lawrence Brakmo wrote:
[...]
> Daniel, I see value for having a global program, so I would like to keep that. When
> this patchset is accepted, I will submit one that adds support for per cgroup
> sock_ops programs, with the option to use the global one if none is
> specified for a cgroup. We could also have the option of the cgroup sock_ops
> program choosing if the global program should run for a particular op based on
> its return value. We can iron it out the details when that patch is submitted.

Hm, could you elaborate on the value part compared to per cgroups ops?
My understanding is that per cgroup would already be a proper superset
of just the global one anyway, so why not going with that in the first
place since you're working on it?

What would be the additional value? How would global vs per cgroup one
interact with each other in terms of enforcement e.g., there's already
semantics in place for cgroups descendants, would it be that we set
TCP parameters twice or would you disable the global one altogether?
Just wondering as you could avoid these altogether with going via cgroups
initially.

Thanks,
Daniel
