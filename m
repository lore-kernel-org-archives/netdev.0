From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] act_bpf: add initial eBPF support for
 actions
Date: Fri, 20 Mar 2015 15:30:49 +0100
Message-ID: <20150320143049.GG2223@nanopsycho.brq.redhat.com>
References: <cover.1426859241.git.daniel@iogearbox.net>
 <6fcca3889ace4f7f090470e50a001aca721bd0d9.1426859241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38469 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbCTOaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:30:52 -0400
Received: by wibgn9 with SMTP id gn9so16113309wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 07:30:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6fcca3889ace4f7f090470e50a001aca721bd0d9.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 20, 2015 at 03:11:12PM CET, daniel@iogearbox.net wrote:
>This work extends the "classic" BPF programmable tc action by extending
>its scope also to native eBPF code!
>
>Together with commit e2e9b6541dd4 ("cls_bpf: add initial eBPF support
>for programmable classifiers") this adds the facility to implement fully
>flexible classifier and actions for tc that can be implemented in a C
>subset in user space, "safely" loaded into the kernel, and being run in
>native speed when JITed.
>
>Also, since eBPF maps can be shared between eBPF programs, it offers the
>possibility that cls_bpf and act_bpf can share data 1) between themselves
>and 2) between user space applications. That means that, f.e. customized
>runtime statistics can be collected in user space, but also more importantly
>classifier and action behaviour could be altered based on map input from
>the user space application.
>
>For the remaining details on the workflow and integration, see the cls_bpf
>commit e2e9b6541dd4. Preliminary iproute2 part can be found under [1].
>
>  [1] http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf-act
>
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Cc: Jiri Pirko <jiri@resnulli.us>

Would be easier to review without the variable renames.

But still, I like this a lot! Thanks!

Acked-by: Jiri Pirko <jiri@resnulli.us>
