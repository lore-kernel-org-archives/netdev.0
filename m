From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Mon, 13 Jun 2016 17:52:47 -0400
Message-ID: <575F2B2F.2030104@mojatatu.com>
References: <1465766693-2336-1-git-send-email-jhs@emojatatu.com>
 <575E681B.8080500@iogearbox.net> <575E9E7E.6000507@mojatatu.com>
 <575EA537.9010807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, fw@strlen.de
To: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35068 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161258AbcFMVwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:52:55 -0400
Received: by mail-it0-f65.google.com with SMTP id e5so8914423ith.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:52:54 -0700 (PDT)
In-Reply-To: <575EA537.9010807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 08:21 AM, Daniel Borkmann wrote:

>
> Looks like nft_meta_set_eval() can already do that, but restricted
> via pkt_type_ok(), so we can't play bad games with PACKET_LOOPBACK
> et al. Wasn't aware of that. Hm, so if you want to make use of this
> from tc as well, probably it makes sense to add a generic helper as
> in skb_pkt_type_mangle() and place it into skbuff.h?
>

Ok, will do with next update.

cheers,
jamal
