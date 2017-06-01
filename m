From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 11:51:24 -0600
Message-ID: <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
 <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
 <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>, Jakub Kicinski <kubakici@wp.pl>,
        Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36701 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbdFARv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:51:28 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so7943111pfb.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 10:51:28 -0700 (PDT)
In-Reply-To: <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 11:24 AM, Alexei Starovoitov wrote:
> 
> what problem are we trying to solve?
> If we don't agree on the problem, we won't be able to agree on the
> solution.

I want the ability to retrieve the BPF instructions pushed to the
kernel. Not just for cgroups and VRF, but everywhere - cgroups, sockets,
xdp, filters, etc. I have this stated many times, including to you at
netconf in April. From that discussion and the discussion on the RFC
patch I sent in February, I thought we had an agreement that saving the
instructions was the first step.

Quentin at 6wind has expressed a similar interest for cls_bpf and
act_bpf code.

I read Jakub's email as wanting the same but for XDP.

The patches I referenced earlier save the original instructions and
enable them to be read by userspace from an fd return by the bpf
syscall. Combine that with the ID and we have a solution.
