From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next v2] tc, bpf: finalize eBPF support for
 cls and act front-end
Date: Wed, 01 Apr 2015 09:02:38 -0700
Message-ID: <551C169E.1080105@plumgrid.com>
References: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, jhs@mojatatu.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34144 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbDAQCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 12:02:40 -0400
Received: by iedfl3 with SMTP id fl3so52724789ied.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 09:02:40 -0700 (PDT)
In-Reply-To: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/15 8:57 AM, Daniel Borkmann wrote:
> This work finalizes both eBPF front-ends for the classifier and action
> part in tc, it allows for custom ELF section selection, a simplified tc
> command frontend (while keeping compat), reusing of common maps between
> classifier and actions residing in the same object file, and exporting
> of all map fds to an eBPF agent for handing off further control in user
> space.
>
> It also adds an extensive example of how eBPF can be used, and a minimal
> self-contained example agent that dumps map data. The example is well
> documented and hopefully provides a good starting point into programming
> cls_bpf and act_bpf.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

great work!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
