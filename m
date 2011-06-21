From: Victor Julien <victor@inliniac.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 15:27:54 +0200
Message-ID: <4E009C5A.8060208@inliniac.net>
References: <20110621.025334.547463578193934724.davem@davemloft.net> <4E0074CF.8070003@inliniac.net> <20110621.034627.30677905865798284.davem@davemloft.net> <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:46570 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab1FUN2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 09:28:20 -0400
In-Reply-To: <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2011 03:05 PM, Changli Gao wrote:
> On Tue, Jun 21, 2011 at 6:46 PM, David Miller <davem@davemloft.net> wrote:
>> From: Victor Julien <victor@inliniac.net>
>> Date: Tue, 21 Jun 2011 12:39:11 +0200
>>
>>> The hash based on skb->rxhash, does that result in a "flow" based
>>> distribution over the listeners? So all packets sharing a tuple
>>> being sent to the same socket?
>>
>> Yes, that's exactly right.
> 
> But not for fragments, in additional.

>From a Suricata IDS point of view, I would need to have the fragments of
a flow/tuple on the same socket.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

