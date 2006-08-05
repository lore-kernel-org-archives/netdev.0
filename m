From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: IPV6 possible recursive locking
Date: Fri, 04 Aug 2006 17:56:27 -0700
Message-ID: <44D3ECBB.6060901@linux.intel.com>
References: <E1G99sr-0004a2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Petr Vandrovec <vandrove@vc.cvut.cz>, netdev@vger.kernel.org,
	mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30469 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1422686AbWHEA7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 20:59:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G99sr-0004a2-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
>>  [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
>>  [<ffffffff812f6fb1>] inet_csk_clone+0x11/0x70
>>  [<ffffffff81300b94>] tcp_create_openreq_child+0x24/0x480
>>  [<ffffffff8136e7c2>] tcp_v6_syn_recv_sock+0x2c2/0x6f0
>>  [<ffffffff81301219>] tcp_check_req+0x229/0x3a0
>>  [<ffffffff8136d7bd>] tcp_v6_do_rcv+0x17d/0x400
>>  [<ffffffff81370215>] tcp_v6_rcv+0x7e5/0x850
> 
> Yes this is a known problem.  The lock validator needs to learn how
> to distinguish between parent and child sockets.

Hmm I remember fixing sk_clone before.. or was that skb_clone, I'd have ot check.
Anyway I'll check this out either later today or tomorrow in more detail
and will send a patch.
