From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Mon, 14 Nov 2011 12:38:28 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111141237410.26961@frira.zrqbmnf.qr>
References: <0hivdsb.f18682ec9367f08c76301d993553f1b8@obelix.schillstrom.com> <20111108105110.GA15798@1984> <20111113170528.GB16851@1984> <201111141019.43423.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:53664 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956Ab1KNLia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 06:38:30 -0500
In-Reply-To: <201111141019.43423.hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2011-11-14 10:19, Hans Schillstrom wrote:

>
>On Sunday, November 13, 2011 18:05:28 Pablo Neira Ayuso wrote:
>> BTW, I think you should split xt_HMARK to ipt_HMARK and ip6t_HMARK
>> (see recent Florian Westphal patches regarding reserve lookup for
>> instance).
>> 
>> The IPv4 and IPv6 parts for HMARK look so different that I don't think
>> it makes sense to keep them into one single xt_HMARK thing with all
>> those conditional ifdefs for IPV6.
>>
>Ok I'll do that, for some reason a thought it was better with one module.

So do I. The module overhead is so much larger.
