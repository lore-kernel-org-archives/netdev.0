From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 22:40:08 +0200
Message-ID: <554FC228.2010804@iogearbox.net>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-3-git-send-email-pablo@netfilter.org> <554F9946.9040707@plumgrid.com> <20150510175934.GA3799@salvia> <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Alexei Starovoitov <ast@plumgrid.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43581 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbEJUkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 16:40:14 -0400
In-Reply-To: <554FA7A5.5020400@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2015 08:47 PM, Alexei Starovoitov wrote:
...
> You've read the patch in a way that it slows down netif_receive
> _without_ ingress qdisc? Of course, that's not the case.
>
> Here are the number from my box:
> before:
> no ingress - 37.6
> ingress on other dev - 36.5
> ingress on this dev - 28.8
> ingress on this dev + u32 - 24.1
>
> after Daniel's two patches:
> no ingress - 37.6
> ingress on other dev - 36.5
> ingress on this dev - 36.5
> ingress on this dev + u32 - 25.2
>
> so when ingress qdisc is not used, the difference is zero.
> When ingress qdisc is added to another device - difference is zero.
> The last two numbers that we wanted to accelerate and we did.

+1, exactly!
