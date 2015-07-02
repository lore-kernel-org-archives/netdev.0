From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 4/6] net_sched: act: use a separate packet counters
 for gact_determ()
Date: Thu, 02 Jul 2015 08:44:52 -0700
Message-ID: <55955C74.1080406@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-5-git-send-email-edumazet@google.com>
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
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36472 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbGBPo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 11:44:59 -0400
Received: by oiaf66 with SMTP id f66so27197180oia.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 08:44:57 -0700 (PDT)
In-Reply-To: <1435842455-30501-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> Second step for gact RCU operation :
> 
> We want to get rid of the spinlock protecting gact operations.
> Stats (packets/bytes) will soon be per cpu.
> 
> gact_determ() would not work without a central packet counter,
> so lets add it for this mode.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>
