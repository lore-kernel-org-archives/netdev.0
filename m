From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Thu, 30 Jun 2016 15:42:56 -0700
Message-ID: <CAM_iQpXtOr+AD2_q1E_dZm8MmLFAhdqPb6-_3ChgCr38gKi0yg@mail.gmail.com>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com> <57757823.4090000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33379 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbcF3Wn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 18:43:29 -0400
Received: by mail-qk0-f171.google.com with SMTP id o76so59907453qke.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 15:43:16 -0700 (PDT)
In-Reply-To: <57757823.4090000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 12:50 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Maybe makes sense to move skb_push_rcsum() but /also/ skb_pull_rcsum()
> to the header then? Both seem similarly small at least (could be split
> f.e into two patches then, first for the move, second for the actual fix).

No objection from me. Please feel free to send a patch. ;)
