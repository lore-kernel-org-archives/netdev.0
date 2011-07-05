From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: IPv6 destination cache in Linux kernel
Date: Tue, 05 Jul 2011 13:58:58 -0600
Message-ID: <4E136D02.3060302@genband.com>
References: <CF5C0F47-9A82-44CF-8441-AC23C26E476B@gmail.com> <20110704.174619.1196575558517508080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mparemm@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:55132 "EHLO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab1GET7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:59:03 -0400
In-Reply-To: <20110704.174619.1196575558517508080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2011 06:46 PM, David Miller wrote:
> From: Mikhail Paremski<mparemm@gmail.com>
> Date: Mon, 4 Jul 2011 17:35:04 -0700
>
>> 1. What are the reasons to rout datagrams differently fromIPv4?
>
> It was just a design decision made when the ipv6 routing code
> was implemented.

Presumably there was some rationale for doing it differently than the 
existing IPv4 code.  Or was it just for fun?

>> 2. Where I could get details how IPv6 stack routes datagrams?
>
> By reading the source code.

While the source code has the final say, for someone new to a given part 
of the kernel it is helpful to have a high-level view of the overall 
flow.  It's a lot easier to understand something if you can place it in 
the overall scheme of of things.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
