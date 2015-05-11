From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 06/15] net: move __skb_tx_hash to skbuff.c
Date: Mon, 11 May 2015 18:01:28 +0200
Message-ID: <20150511160128.GC2222@nanopsycho.mtl.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
 <1431177038-11555-7-git-send-email-jiri@resnulli.us>
 <5550D0DF.7090806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com, kaber@trash.net,
	therbert@google.com, edumazet@google.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37409 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbbEKQBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:01:34 -0400
Received: by widdi4 with SMTP id di4so102135789wid.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:01:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5550D0DF.7090806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 11, 2015 at 05:55:11PM CEST, alexander.h.duyck@redhat.com wrote:
>On 05/09/2015 06:10 AM, Jiri Pirko wrote:
>>__skb_tx_hash function has no relation to flow_dissect so just muve it
>>to skbuff.c (it is declared in skbuff.h)
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Minor nit, move is spelled with an o, not a u.

Noted.

>
>Also any reason for moving this to skbuff.c instead of dev.c?  It seems like
>this might be better placed there since the only caller is in netdevice.h.

Okay.

>
>- Alex
