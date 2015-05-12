From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 06/15] net: move __skb_tx_hash to skbuff.c
Date: Tue, 12 May 2015 07:22:29 +0200
Message-ID: <20150512052229.GA1983@nanopsycho>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
 <1431177038-11555-7-git-send-email-jiri@resnulli.us>
 <CAHA+R7N=GvTP+A8P2pRDy2PzBgd5M=5F_+GsonBwpTqJV6e7ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34965 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbbELFWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 01:22:46 -0400
Received: by wgbhc8 with SMTP id hc8so51552245wgb.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 22:22:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7N=GvTP+A8P2pRDy2PzBgd5M=5F_+GsonBwpTqJV6e7ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 12, 2015 at 01:21:01AM CEST, cwang@twopensource.com wrote:
>On Sat, May 9, 2015 at 6:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> __skb_tx_hash function has no relation to flow_dissect so just muve it
>> to skbuff.c (it is declared in skbuff.h)
>>
>
>It calls __skb_get_hash() in most of the cases, and __skb_get_hash()
>is in flow_dissector.c.
>
>There are many functions declared in skbuff.h but defined in a different
>file than skbuff.c.
>
>Why bother?

To make this a little bit cleaner?
