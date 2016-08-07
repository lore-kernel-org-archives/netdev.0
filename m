From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next 0/2] BPF, kprobes: Add current_in_cgroup helper
Date: Sat, 6 Aug 2016 21:32:05 -0700
Message-ID: <20160807043203.GA77894@ast-mbp>
References: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35189 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbcHGEed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 00:34:33 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so22643238pfg.2
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 21:34:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 06, 2016 at 09:06:53PM -0700, Sargun Dhillon wrote:
> This patchset includes a helper and an example to determine whether the kprobe 
> is currently executing in the context of a specific cgroup based on a cgroup
> bpf map / array. 

description is too short to understand how this new helper is going to be used.
depending on kprobe current is not always valid.
what are you trying to achieve?
This looks like an alternative to lsm patches submitted earlier?
btw net-next is closed and no new features accepted at the moment.
