From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Mon, 22 Sep 2014 22:11:32 +0200
Message-ID: <CAPh34mdo74StDtpJ_E21jgS2K8P8Y5T24WwDLdOzZs3fNB7_9g@mail.gmail.com>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
	<1411248562-26581-3-git-send-email-fw@strlen.de>
	<20140922092606.10977e48@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	"Eggert, Lars" <lars@netapp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, fontana@sharpeleven.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	glenn.judd@morganstanley.com,
	Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:52486 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaIVULd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:11:33 -0400
Received: by mail-lb0-f178.google.com with SMTP id z12so4869493lbi.37
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:11:32 -0700 (PDT)
In-Reply-To: <20140922092606.10977e48@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 September 2014 18:26, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>> +static inline void
>> +TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
>> +                    const struct sock *listen_sk)
>
> Maybe good time to switch to lower case here for function name.

Probably a follow up patch can convert all of TCP_ECN_* to lower case.

HGN
