From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Wed, 24 May 2006 17:16:52 +0100
Message-ID: <447486F4.1050307@ev-en.org>
References: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:29645
	"EHLO galon.ev-en.org") by vger.kernel.org with ESMTP
	id S932362AbWEXQRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 12:17:01 -0400
To: #ZHOU BIN# <ZHOU0022@ntu.edu.sg>
In-Reply-To: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

#ZHOU BIN# wrote:
> From: Bin Zhou <zhou0022@ntu.edu.sg>
> +		else if (sysctl_tcp_abc) {
> + 			/* RFC3465: Apppriate Byte Count
> + 	 		* increase once for each full cwnd acked.
> + 	 		* Veno has no idear about it so far, so we keep
> + 	 		* it as Reno.
> + 	 		*/
> + 			if (tp->bytes_acked >= tp->snd_cwnd*tp->mss_cache) {
> + 				tp->bytes_acked -= tp->snd_cwnd*tp->mss_cache;
> + 				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
> + 					tp->snd_cwnd++;
> + 			}

You should prefer to ignore abc instead. At least that's what everyone
else is doing, the only place where abc is active is in NewReno.

Baruch
