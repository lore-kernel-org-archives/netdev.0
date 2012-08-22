From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: [PATCH] ipv4: properly update pmtu
Date: Wed, 22 Aug 2012 12:16:16 +0200
Message-ID: <CAF6-1L77Z23dCfnee3nO3-V9U_tc1jz0ptXf9YcBcARGYnOvsw@mail.gmail.com>
References: <1345618109.5158.599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:59536 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab2HVKQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 06:16:17 -0400
Received: by vcbfk26 with SMTP id fk26so848925vcb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 03:16:17 -0700 (PDT)
In-Reply-To: <1345618109.5158.599.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> From: Eric Dumazet <edumazet@google.com>

> ip_rt_update_pmtu() calls dst_set_expires() to rearm a new expiration,
> but dst_set_expires() does nothing because dst.expires is already set.
>
> It seems we want to set the expires field to a new value, regardless
> of prior one.
>
> With help from Julian Anastasov.
>
> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> CC: Julian Anastasov <ja@ssi.bg>

Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>

I confirm this corrects the issue for me. I tested this on 3 machines
with 2 different hw config that all previously exhibited the issue
short after boot and now they've been running with this version of the
patch for hours without problems.

@Eric: Thanks for looking into this.


Cheers,

    Sylvain
