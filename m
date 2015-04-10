From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v2] tc, bpf: finalize eBPF support for
 cls and act front-end
Date: Fri, 10 Apr 2015 13:35:33 -0700
Message-ID: <20150410133533.7eba5137@urahara>
References: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33136 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194AbbDJUfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:35:31 -0400
Received: by pdbnk13 with SMTP id nk13so33482797pdb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:35:30 -0700 (PDT)
In-Reply-To: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  1 Apr 2015 17:57:44 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

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
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Applied to net-next branch of iproute2
