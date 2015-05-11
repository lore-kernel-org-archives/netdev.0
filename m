From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next 06/15] net: move __skb_tx_hash to skbuff.c
Date: Mon, 11 May 2015 16:21:01 -0700
Message-ID: <CAHA+R7N=GvTP+A8P2pRDy2PzBgd5M=5F_+GsonBwpTqJV6e7ZQ@mail.gmail.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
	<1431177038-11555-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36203 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbEKXVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 19:21:03 -0400
Received: by wizk4 with SMTP id k4so126880923wiz.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 16:21:01 -0700 (PDT)
In-Reply-To: <1431177038-11555-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 9, 2015 at 6:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> __skb_tx_hash function has no relation to flow_dissect so just muve it
> to skbuff.c (it is declared in skbuff.h)
>

It calls __skb_get_hash() in most of the cases, and __skb_get_hash()
is in flow_dissector.c.

There are many functions declared in skbuff.h but defined in a different
file than skbuff.c.

Why bother?
