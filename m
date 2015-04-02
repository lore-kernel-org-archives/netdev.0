From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 -next v2] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Thu, 2 Apr 2015 08:22:32 +0200
Message-ID: <20150402062232.GA2613@nanopsycho.orion>
References: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, ast@plumgrid.com, jhs@mojatatu.com,
	tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36719 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbDBGWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 02:22:37 -0400
Received: by wgra20 with SMTP id a20so74808087wgr.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 23:22:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 01, 2015 at 05:57:44PM CEST, daniel@iogearbox.net wrote:
>This work finalizes both eBPF front-ends for the classifier and action
>part in tc, it allows for custom ELF section selection, a simplified tc
>command frontend (while keeping compat), reusing of common maps between
>classifier and actions residing in the same object file, and exporting
>of all map fds to an eBPF agent for handing off further control in user
>space.
>
>It also adds an extensive example of how eBPF can be used, and a minimal
>self-contained example agent that dumps map data. The example is well
>documented and hopefully provides a good starting point into programming
>cls_bpf and act_bpf.
>
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>Cc: Alexei Starovoitov <ast@plumgrid.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks Daniel!
