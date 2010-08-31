From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Tue, 31 Aug 2010 21:57:49 +0200
Message-ID: <4C7D5EBD.103@gmail.com>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com> <20100831210101.3c059a91@leibniz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@osdl.org>
To: Dan Kruchinin <dkruchinin@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53690 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab0HaT5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 15:57:55 -0400
Received: by fxm13 with SMTP id 13so4236552fxm.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 12:57:54 -0700 (PDT)
In-Reply-To: <20100831210101.3c059a91@leibniz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Kruchinin wrote, On 08/31/2010 07:01 PM:

> I'm sorry it seems my email client has broken patch formating.
> Here is properly formated one:
> diff --git a/tc/q_tbf.c b/tc/q_tbf.c
> index dc556fe..850e6db 100644
> --- a/tc/q_tbf.c
> +++ b/tc/q_tbf.c
> @@ -178,7 +178,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
>  	}
>  
>  	if (opt.limit == 0) {
> -		double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
> +		double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC;

The way limit is calculated here from latency suggests some safety defaults
are taken wrt. the implementation, which could be omitted while setting the
limit directly. You try to change/fix this to adhere to the documentation,
but such a change would definitely break many user configs, so I doubt it's
the right solution here. Probably you should rather think about fixing the
manual.

Thanks,
Jarek P.

