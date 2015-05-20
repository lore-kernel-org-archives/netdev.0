From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier
 module unloads
Date: Wed, 20 May 2015 11:36:43 -0700
Message-ID: <1432147003.4060.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
	 <CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com>
	 <555CCE89.10503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	subramanian.vijay@gmail.com, netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33919 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbbETSgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:36:45 -0400
Received: by igbhj9 with SMTP id hj9so69143984igb.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:36:45 -0700 (PDT)
In-Reply-To: <555CCE89.10503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 20:12 +0200, Daniel Borkmann wrote:

> Effectively, every in-tree classifier (rsvp is the only exception)
> is making use of call_rcu(). Moreover, moving this into every
> ->destroy() handler would also be unnecessary overhead, imho, as
> this is only relevant when we actually _unload_ a module.

I kind of agree with you, not sure there is any gain from spreading this
fix all over the places.

Acked-by: Eric Dumazet <edumazet@google.com>
