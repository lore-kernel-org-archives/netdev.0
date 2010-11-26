From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100% reproductiblle,
 works under guest. no way to protect :(
Date: Fri, 26 Nov 2010 15:41:24 +0800
Message-ID: <4CEF64A4.5080802@cn.fujitsu.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>	 <1290666501.2798.84.camel@edumazet-laptop>	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>	 <1290668246.2798.93.camel@edumazet-laptop>	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>	 <1290672978.2798.151.camel@edumazet-laptop>	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com> <1290694299.2858.330.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63946 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752539Ab0KZHnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 02:43:08 -0500
In-Reply-To: <1290694299.2858.330.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 11/25/2010 10:11 PM:
> @@ -1845,6 +1871,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		unix_state_lock(sk);
>  		skb = skb_dequeue(&sk->sk_receive_queue);
>  		if (skb == NULL) {
> +			unix_sk(sk)->recursion_level = 0;

For SOCK_SEQPACKET type, no need to clear recursion_level counter?
 

-- 
Best Regards
-----
Shan Wei
