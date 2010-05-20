From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute] ip: add support for multicast rules
Date: Thu, 20 May 2010 16:01:56 +0200
Message-ID: <4BF540D4.1030903@trash.net>
References: <4BC48870.7070704@trash.net> <20100519090354.6dc6d82b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab0ETOBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 10:01:55 -0400
In-Reply-To: <20100519090354.6dc6d82b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 13 Apr 2010 17:06:24 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> This patch adds support for a "ip mrule" command, which is used
>> to configure multicast routing rules.
>>
>> The corresponding kernel patches have been sent to Dave and
>> should (hopefully) appear in net-next soon.
> 
> The fib_rules.h file in iproute2 is kept in sync with the kernel
> headers. But I do not see the definitions of FIB_RULES_IPV4 etc
> in net-next kernel.  What happened to this?

Those got changed again during the addition of IPv6 support.
I'll send a new version shortly, including IPv6 support.
