From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 15:44:19 -0700
Message-ID: <444FF7C3.80801@hp.com>
References: <44493980.1040708@oracle.com> <444E31D9.1010705@psc.edu>	<20060426.144540.39973302.davem@davemloft.net>	<444FF132.2080505@hp.com> <20060426152738.3a50d645@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jheffner@psc.edu,
	zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:24227 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S964877AbWDZWoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 18:44:23 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060426152738.3a50d645@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>BTW, is the RFC 2681?  I looked that one up on ietf.org and the RFC by 
>>that number was a different beast entirely - at least at a very quick 
>>glance.
>>
>>rick jones
>>-
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> http://www.faqs.org/rfcs/rfc2861.html

thanks.

>    Long periods when the sender is application-limited can lead to the
>    invalidation of the congestion window.  During periods when the TCP
>    sender is network-limited, the value of the congestion window is
>    repeatedly "revalidated" by the successful transmission of a window
>    of data without loss.  When the TCP sender is network-limited, there
>    is an incoming stream of acknowledgements that "clocks out" new data,
>    giving concrete evidence of recent available bandwidth in the
>    network.  In contrast, during periods when the TCP sender is
>    application-limited, the estimate of available capacity represented
>    by the congestion window may become steadily less accurate over time.
>    In particular, capacity that had once been used by the network-
>    limited connection might now be used by other traffic.

May, might, could... :)

What concerned me the most was section 5, where the experiments were for 
dial-up connections and an interactive user then cat'ing a large file to 
the screen.  How often does someone "list a moderately large file" 
without using less or more?  And the bit about the second experiment 
with the real modem bank not showing any difference in what the user 
experienced because the bank had buffering was interesting.  It suggests 
  (to me anyway) that perhaps the TCP receive window was too large for a 
modem connection in the first place.  Leaves me wondering what effect 
Linux's moderated receive window would have on that experiment.

rick jones
