From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Tue, 23 Sep 2014 11:17:17 +0200
Message-ID: <54213A9D.6060400@redhat.com>
References: <1411248562-26581-1-git-send-email-fw@strlen.de> <1411248562-26581-3-git-send-email-fw@strlen.de> <20140922092606.10977e48@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
	hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbaIWJRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 05:17:38 -0400
In-Reply-To: <20140922092606.10977e48@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On 09/22/2014 06:26 PM, Stephen Hemminger wrote:
> On Sat, 20 Sep 2014 23:29:19 +0200
> Florian Westphal <fw@strlen.de> wrote:
>
>> +static inline void
>> +TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
>> +		       const struct sock *listen_sk)
>
> Maybe good time to switch to lower case here for function name.

thanks for your feedback and review, much appreciated! I think
it makes sense and we would send a follow-up clean-up patch that
replaces TCP_ECN_* with tcp_ecn_* in this and other function names.

Thanks,

Daniel, Florian
