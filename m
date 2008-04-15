From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 15:10:48 +0200
Message-ID: <4804A958.4020708@trash.net>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local> <4804A18C.2060200@trash.net> <20080415130045.GB4993@ff.dom.local> <4804A921.6050509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36711 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbYDONKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 09:10:50 -0400
In-Reply-To: <4804A921.6050509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Jarek Poplawski wrote:

>>> I don't think we should do that, it would be preferable to
>>> compare the entire handle instead of just the major to avoid
>>> this.
>>
>> Probably you are right... I guess you could handle this?
> 
> 
> On second thought I agree with you, the behaviour is inconsistent
> and FFFF: shouldn't be used as major, otherwise the major doesn't
> uniquely identify a qdisc anymore.
> 

> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index fc8708a..c486e9d 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c


That patch shouldn't have been there, please ignore :)
