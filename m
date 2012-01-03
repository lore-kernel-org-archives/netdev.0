From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: Fix bug in ofo queue pruning MIB stats
Date: Tue, 03 Jan 2012 15:10:41 -0800
Message-ID: <4F038AF1.3040307@hp.com>
References: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com> <20111221.193315.2134174670572741208.davem@davemloft.net> <CAGK4HS8g41A8KB9iqyabZN85Ytgb+HPk3wwvoOuwkk8s9+iuCA@mail.gmail.com> <20111221.221511.1067604757446412302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43009 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab2ACXKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 18:10:44 -0500
In-Reply-To: <20111221.221511.1067604757446412302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 07:15 PM, David Miller wrote:
> From: Vijay Subramanian<subramanian.vijay@gmail.com>
> Date: Wed, 21 Dec 2011 17:14:05 -0800
>
>> If the counter is tracking the right thing, is it worth fixing
>> netstat?
>
> Probably.
>
> The thing is, I can see both intepretations being useful.
>
> If we count packets, we can't tell that OFO pruning happened 4 times
> vs. we pruned 4 packets.
>
> But if you want to know the "extent" to which OFO pruning occurs, then
> you want the packet count.

Starting from the premise that the *primary* goal of netstat is to allow 
end users/admins to know about packet loss events and how they correlate 
with retransmissions, were I to have a "vote" it would be "count the 
packets."

rick jones
