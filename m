From: Florian Westphal <fw@strlen.de>
Subject: Re: [Suggestion] net/netfilter: strcpy for timeout->name
Date: Wed, 21 Nov 2012 12:39:01 +0100
Message-ID: <20121121113901.GA25102@breakpoint.cc>
References: <50AB0249.20802@asianux.com>
 <50AB12EE.6050802@gmail.com>
 <50AB4386.3080603@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xue Ying <ying.xue0@gmail.com>, David Miller <davem@davemloft.net>,
	Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:32805 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753542Ab2KULjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:39:31 -0500
Content-Disposition: inline
In-Reply-To: <50AB4386.3080603@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang <gang.chen@asianux.com> wrote:
> Please help checking net/netfilter/nfnetlink_cttimeout.c:
>   I suggest, we use strncpy instead of strcpy at line 143. 
>   just like we have already used strncmp at line 94.
[..]
>   after checking the calling work flow:
>     the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in server side.

Good catch, classic buffer overflow.

I've sent a patch to add the missing "len" policy.  Thanks for reporting
this bug.
