From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: also make sch_handle_egress() drop monitor
 ready
Date: Sun, 15 May 2016 14:59:52 -0700
Message-ID: <20160515215950.GA37564@ast-mbp.thefacebook.com>
References: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35001 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbcEOWAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 18:00:07 -0400
Received: by mail-pa0-f65.google.com with SMTP id zy2so15215262pac.2
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 14:59:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 11:28:29PM +0200, Daniel Borkmann wrote:
> Follow-up for 8a3a4c6e7b34 ("net: make sch_handle_ingress() drop
> monitor ready") to also make the egress side drop monitor ready.
> 
> Also here only TC_ACT_SHOT is a clear indication that something
> went wrong. Hence don't provide false positives to drop monitors
> such as 'perf record -e skb:kfree_skb ...'.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
