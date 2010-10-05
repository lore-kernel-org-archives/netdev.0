From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Mon, 04 Oct 2010 22:47:35 -0700 (PDT)
Message-ID: <20101004.224735.191411120.davem@davemloft.net>
References: <20101001124830.9c35d36f.sfr@canb.auug.org.au>
	<AANLkTinsNEeTK=SrGpqEjF8VtZZWpiWydgSc+3M854pD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	damian@tvk.rwth-aachen.de
To: hkchu@google.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <AANLkTinsNEeTK=SrGpqEjF8VtZZWpiWydgSc+3M854pD@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jerry Chu <hkchu@google.com>
Date: Thu, 30 Sep 2010 20:27:05 -0700

> In tcp_write_timeout():
> 
> if (retransmits_timed_out(sk, retry_until,
>             (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV) ? 0 :
>             icsk->icsk_user_timeout, syn_set)) {
> 
> should be simplified to
> 
> if (retransmits_timed_out(sk, retry_until,
>     syn_set ? 0 : icsk->icsk_user_timeout, syn_set)) {

I've merged net-2.6 into net-next-2.6 and integrated this simplification
while doing so.
