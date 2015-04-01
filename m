From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Wed, 01 Apr 2015 08:36:06 -0400
Message-ID: <551BE636.7040505@mojatatu.com>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36331 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbbDAMgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:36:08 -0400
Received: by iedm5 with SMTP id m5so41434201ied.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 05:36:08 -0700 (PDT)
In-Reply-To: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/15 18:35, Daniel Borkmann wrote:
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

This is excellent work Daniel.
The patch is large that it would be hard to provide good code
feedback. I will wait for your next iteration and whatever Alexei ends
up putting out.

I have an observation:
I realize you are doing this to illustrate the power of ebpf. And it
is impressive. Do you see this as a way to replace pieces of the
kernel stack or to aid and abate what the kernel already does?
I am looking at this and i see ability to inject arbitrary code into
the kernel. It is probably no different than someone writing DPDK code
but this is in the kernel.
How do we not help vendors achieve that goal or put another
way: how do we not help vendors direct their resources at improving the
linux infrastructure with this?

cheers,
jamal
