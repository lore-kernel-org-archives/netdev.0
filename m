From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv4 net-next 00/15] BPF hardware offload (cls_bpf for now)
Date: Thu, 15 Sep 2016 13:16:50 -0700
Message-ID: <20160915201649.GA74880@ast-mbp.thefacebook.com>
References: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35706 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbcIOUQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:16:55 -0400
Received: by mail-pa0-f42.google.com with SMTP id oz2so14434795pac.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:16:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:12:20PM +0100, Jakub Kicinski wrote:
> In the last year a lot of progress have been made on offloading
> simpler TC classifiers.  There is also growing interest in using
> BPF for generic high-speed packet processing in the kernel.
> It seems beneficial to tie those two trends together and think
> about hardware offloads of BPF programs.  This patch set presents
> such offload to Netronome smart NICs.  cls_bpf is extended with
> hardware offload capabilities and NFP driver gets a JIT translator
> which in presence of capable firmware can be used to offload
> the BPF program onto the card.

Looks great! Thanks for all the hard work.
