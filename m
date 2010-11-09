From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 13:10:53 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011091303250.21752@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Holger Eitzenberger <heitzenberger@astaro.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:37342 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab0KIMKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 07:10:54 -0500
In-Reply-To: <4CD6DF37.6010800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2010-11-07 18:17, Patrick McHardy wrote:
>On 07.11.2010 17:44, Jan Engelhardt wrote:
>> we mentioned it only briefly at the Netfilter workshop a few weeks ago, 
>> but as I am trying to figure out how to use Netlink in Xtables, 
>> Netlink's limitations really start ruining my day.
>> 
>> The well-known issue is that NL messages[sic] the kernel is supposed to 
>> receive have a max size of 64K, due to nlmsghdr's use of uint16_t. This 
>> is very problematic because attributes can easily amass more than 64K. 
>> Think of a chain full of rules, represented by a top-level attribute 
>> that nests attributes. The problem is bidirectional, a table 
>> dump has the same problem.
>
>Messages are not limited to 64k, individual attributes are. Holger
>started working on a nlattr32, which uses 32 bit for the length
>value.

Does he have a format specification available?
