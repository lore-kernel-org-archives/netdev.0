From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 1/7] net: sched: extend percpu stats helpers
Date: Mon, 06 Jul 2015 11:34:00 -0700
Message-ID: <559ACA18.70802@plumgrid.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com> <1436185089-18268-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36176 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbbGFSeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 14:34:03 -0400
Received: by pddu5 with SMTP id u5so22809049pdd.3
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 11:34:02 -0700 (PDT)
In-Reply-To: <1436185089-18268-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15 5:18 AM, Eric Dumazet wrote:
> qdisc_bstats_update_cpu() and other helpers were added to support
> percpu stats for qdisc.
>
> We want to add percpu stats for tc action, so this patch add common
> helpers.
>
> qdisc_bstats_update_cpu() is renamed to qdisc_bstats_cpu_update()
> qdisc_qstats_drop_cpu() is renamed to qdisc_qstats_cpu_drop()
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
