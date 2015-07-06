From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net_sched: act: lockless operation
Date: Mon, 6 Jul 2015 08:49:52 +0200
Message-ID: <CANn89iJUGm8FHE1Vn_Qqz8Hi_VU4q22WuqSBmgXjT2JvONwM1Q@mail.gmail.com>
References: <1436164896-8243-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33059 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbbGFGtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 02:49:53 -0400
Received: by wiwl6 with SMTP id l6so274924620wiw.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 23:49:52 -0700 (PDT)
In-Reply-To: <1436164896-8243-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 8:41 AM, Eric Dumazet <edumazet@google.com> wrote:
> As mentioned by Alexei last week in Budapest, it is a bit weird
> to take a spinlock in order to drop a packet in a tc filter...
>

Arg, please ignore v2, I messed my git send-email command
