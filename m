From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: ptp: move PTP classifier in its own file
Date: Tue, 1 Apr 2014 18:37:01 +0200
Message-ID: <20140401163701.GA4369@netboy>
References: <1396362023-8704-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34340 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbaDAQhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:37:12 -0400
Received: by mail-wi0-f178.google.com with SMTP id bs8so5515996wib.5
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 09:37:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1396362023-8704-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 04:20:23PM +0200, Daniel Borkmann wrote:
> In the kernel tree under tools/net/ we have bpf_asm and bpf_dbg
> tools, so the commented program can simply be translated via
> `./bpf_asm -c prog` where prog is a file that contains the
> commented code. This makes it easily readable/verifiable and when
> there's a need to change something, jump offsets etc do not need
> to be replaced manually which can be very error prone. Instead,
> a newly translated version via bpf_asm can simply replace the old
> code. I have checked opcode diffs before/after and it's the very
> same filter.

I'll take your word for it.

Acked-by: Richard Cochran <richardcochran@gmail.com>
