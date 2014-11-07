From: Brian Haley <brian.haley@hp.com>
Subject: Re: How to make stack send broadcast ARP request when entry is STALE?
Date: Fri, 07 Nov 2014 10:54:30 +0100
Message-ID: <545C96D6.5020204@hp.com>
References: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Ulf samuelsson <netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:52166 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaKGJye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 04:54:34 -0500
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com [15.193.200.69])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 0602460C86
	for <netdev@vger.kernel.org>; Fri,  7 Nov 2014 09:54:34 +0000 (UTC)
In-Reply-To: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 07:48 AM, Ulf samuelsson wrote:
> Have a problem with an HP router at a certain location, which
> is configured to only answer to broadcast ARP requests.
> That cannot be changed.

Sorry to hear about the problem, but my only suggestions would be to try 
the latest firmware and/or put a call in to support.  I don't happen 
work in the division that makes routers...

> The first ARP request the kernel sends out, is a broadcast request,
> which is fine, but after the reply, the kernel sends unicast requests,
> which will not get any replies.

You might be able to hack this by inserting an ebtables rule - check the 
dnat target section of the man page - don't know the exact syntax but it 
would probably end in '-j dnat --to-destination ff:ff:ff:ff:ff:ff'

-Brian
