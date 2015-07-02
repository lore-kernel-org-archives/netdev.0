From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/6] net: sched: add percpu stats to actions
Date: Thu, 02 Jul 2015 08:31:03 -0700
Message-ID: <55955937.2080807@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36322 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbbGBPbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 11:31:09 -0400
Received: by oiaf66 with SMTP id f66so26887833oia.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 08:31:09 -0700 (PDT)
In-Reply-To: <1435842455-30501-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> Reuse existing percpu infrastructure Jonh added for qdisc.
> 
> This patch adds a new cpustats parameter to tcf_hash_create() and all
> actions pass false, meaning this patch should have no effect yet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---
>  include/net/act_api.h    |  4 +++-
>  net/sched/act_api.c      | 44 ++++++++++++++++++++++++++++++++++----------
>  net/sched/act_bpf.c      |  2 +-
>  net/sched/act_connmark.c |  3 ++-
>  net/sched/act_csum.c     |  3 ++-
>  net/sched/act_gact.c     |  3 ++-
>  net/sched/act_ipt.c      |  2 +-
>  net/sched/act_mirred.c   |  3 ++-
>  net/sched/act_nat.c      |  3 ++-
>  net/sched/act_pedit.c    |  3 ++-
>  net/sched/act_simple.c   |  3 ++-
>  net/sched/act_skbedit.c  |  3 ++-
>  net/sched/act_vlan.c     |  3 ++-
>  13 files changed, 57 insertions(+), 22 deletions(-)
> 

Nice.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
