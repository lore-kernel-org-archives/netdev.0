From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier module unloads
Date: Wed, 20 May 2015 11:01:14 -0700
Message-ID: <CAGK4HS8CnaHbLTi_B0jybA2=rojB+R=MAYKTEx_=wu5fqu-jvQ@mail.gmail.com>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34849 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbETSBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:01:14 -0400
Received: by ykec202 with SMTP id c202so18490156yke.2
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:01:14 -0700 (PDT)
In-Reply-To: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  Vijay, can you give this a run on your side? This fixes the panic
>  on my side, thanks!

Thanks for the explanation and patch Daniel !
Yes. This also fixes the crash for me. So,

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Vijay
