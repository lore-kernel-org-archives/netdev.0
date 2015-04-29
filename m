From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/6] ipv6: Remove external dependency on
 rt6i_gateway and RTF_ANYCAST
Date: Wed, 29 Apr 2015 12:02:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504291200430.2286@ja.home.ssi.bg>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com> <1430255273-3045254-3-git-send-email-kafai@fb.com> <alpine.LFD.2.11.1504291106060.1504@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42908 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031665AbbD2JCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 05:02:39 -0400
In-Reply-To: <alpine.LFD.2.11.1504291106060.1504@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 29 Apr 2015, Julian Anastasov wrote:

> 	We then solved it with FLOWI_FLAG_KNOWN_NH flag which
> forces a cached route where rt_gateway is filled with requested

	Sorry, I mean "non-cached", not "cached"...

> nexthop address:

Regards

--
Julian Anastasov <ja@ssi.bg>
