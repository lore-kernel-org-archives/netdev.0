From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:09:58 -0700
Message-ID: <46D5EEB6.3020602@hp.com>
References: <200708292052.NAA21975@tardy.cup.hp.com> <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:60906 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640AbXH2WKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:10:17 -0400
In-Reply-To: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> Hmmm... RFC2988 says:
>    (2.4) Whenever RTO is computed, if it is less than 1 second then the
>          RTO SHOULD be rounded up to 1 second.
> 
>          Traditionally, TCP implementations use coarse grain clocks to
>          measure the RTT and trigger the RTO, which imposes a large
>          minimum value on the RTO.  Research suggests that a large
>          minimum RTO is needed to keep TCP conservative and avoid
>          spurious retransmissions [AP99].  Therefore, this
>          specification requires a large minimum RTO as a conservative
>          approach, while at the same time acknowledging that at some
>          future point, research may show that a smaller minimum RTO is
>          acceptable or superior.
> 
> I went and had a look and this RFC has not been obsoleted. RFC3390
> also backs this assertion up.
> 
> So I'm suspecting that the default should be changed to 1000 to match
> the RFC which would solve this issue. I note that the RFC is a SHOULD
> rather than a MUST. I had a quick look around and not sure why Linux
> overrides the RFC on this one.

If nothing else, 200 ms is a "principle of least surprise" thing since 
that is the current value (in MS) for TCP_RTO_MIN.

rick jones
