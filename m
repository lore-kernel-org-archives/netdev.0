From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: relationship between ingress policer and netfilter hooks?
Date: Tue, 02 Jun 2009 12:24:21 -0600
Message-ID: <4A256E55.9090309@nortel.com>
References: <4A25457F.2070000@nortel.com> <4A255BAC.8070406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:52498 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128AbZFBSY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 14:24:28 -0400
In-Reply-To: <4A255BAC.8070406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Chris Friesen wrote:
> 
>>Hi all,
>>
>>Can someone tell me where the hook is for incoming packets to be sent
>>through the ingress policer?
>>
>>In particular, I'm trying to find out how the ingress traffic shaping
>>hook relates to the various netfilter hooks so that I can set them up to
>>behave nicely together.

> They're not related at all. The ingress qdisc is hooked at
> net/dev/core.c:handle_ing().

Thanks.  Based on that the shaping is done before any of the netfilter
hooks, which is what I was trying to figure out.

On a related note...the deliver_skb() call right before the call to
handle_ing()--is that to allow packet sockets to receive everything that
arrives on the wire even if some of it may be dropped later?

Chris
