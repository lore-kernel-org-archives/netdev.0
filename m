From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 4/5] fou: enable LCO in FOU and GUE
Date: Thu, 7 Jan 2016 19:00:07 +0000
Message-ID: <568EB5B7.9090304@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9CAC.6070906@solarflare.com>
 <CALx6S36K+bXH+U5eGys3aKvxfHOtDAkZEQc1pPgDCiDGdXTw2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:63246 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752189AbcAGTAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:00:34 -0500
In-Reply-To: <CALx6S36K+bXH+U5eGys3aKvxfHOtDAkZEQc1pPgDCiDGdXTw2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/16 18:51, Tom Herbert wrote:
> On Thu, Jan 7, 2016 at 9:13 AM, Edward Cree <ecree@solarflare.com> wrote:
>> @@ -787,7 +786,7 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>>         int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
>>         __be16 sport;
>>
>> -       skb = iptunnel_handle_offloads(skb, csum, type);
>> +       skb = iptunnel_handle_offloads(skb, false, type);
> It might good to have another iptunnel_handle_offloads (lifke
> iptunnel_handle_offloads_nocsum) function that doesn't have csum
> parameter for readability.
I hope to follow up soon with a patch to use LCO for GRE, at which point I
 believe that all callers will be passing false anyway, so the csum_help
 parameter can be removed from the function entirely.

-ed
