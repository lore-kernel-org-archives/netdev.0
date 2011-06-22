From: Victor Julien <victor@inliniac.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Wed, 22 Jun 2011 08:49:59 +0200
Message-ID: <4E019097.7090703@inliniac.net>
References: <20110621.034627.30677905865798284.davem@davemloft.net> <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com> <4E009C5A.8060208@inliniac.net> <20110621.143902.274396574751811372.davem@davemloft.net> <BANLkTinxvHbkCLehJkqoCfryeTqL0zhWiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:49780 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab1FVGu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 02:50:27 -0400
In-Reply-To: <BANLkTinxvHbkCLehJkqoCfryeTqL0zhWiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2011 03:44 AM, Changli Gao wrote:
> On Wed, Jun 22, 2011 at 5:39 AM, David Miller <davem@davemloft.net> wrote:
>> From: Victor Julien <victor@inliniac.net>
>> Date: Tue, 21 Jun 2011 15:27:54 +0200
>>
>>> From a Suricata IDS point of view, I would need to have the
>>> fragments of a flow/tuple on the same socket.
>>
>> Currently you would, they would all go to the first socket in
>> the fanout.
>>
> 
> I think he also needs all the packets belong to the related
> connections are received via the same socket. I am afraid that he has
> to dispatch these kind of packets among the uesrland processes again.
> :)
> 

Indeed. Although in Suricata we *could* work around it as we distribute
the flows over threads, not processes. It would still be messy. For this
to be useful to a tool like Snort (I'm sure they're interested) I think
this would be a deal breaker.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

