From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [patch net-next 06/15] net: move __skb_tx_hash to skbuff.c
Date: Mon, 11 May 2015 08:55:11 -0700
Message-ID: <5550D0DF.7090806@redhat.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us> <1431177038-11555-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, hannes@stressinduktion.org, ast@plumgrid.com,
	daniel@iogearbox.net, herbert@gondor.apana.org.au,
	cwang@twopensource.com, john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932300AbbEKPzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 11:55:15 -0400
In-Reply-To: <1431177038-11555-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2015 06:10 AM, Jiri Pirko wrote:
> __skb_tx_hash function has no relation to flow_dissect so just muve it
> to skbuff.c (it is declared in skbuff.h)
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Minor nit, move is spelled with an o, not a u.

Also any reason for moving this to skbuff.c instead of dev.c?  It seems 
like this might be better placed there since the only caller is in 
netdevice.h.

- Alex
