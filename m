From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Thu, 05 Jun 2008 14:50:39 -0700
Message-ID: <48485FAF.6010801@hp.com>
References: <200806011515.14103.maximlevitsky@gmail.com>	<20080604141533.35eb6df0@extreme> <484707D9.3040900@hp.com> <200806060031.16827.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:33185 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbYFEVum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 17:50:42 -0400
In-Reply-To: <200806060031.16827.maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky wrote:
> On Thursday, 5 June 2008 00:23:37 Rick Jones wrote:
>>Would you have it done even for those endpoints on which SO_KEEPALIVE 
>>wasn't set?
> 
> 
> Why not?

Apart from just general paranoia?  Nothing besides perhaps spite for 
having to cover the backside of an application which on the surface at 
least does not appear to have attempted to make itself suspend/resume 
friendly :)  Although how TCP could tell an application with its own 
keepalive vs one that simply didn't bother I'm not at all sure.

> This seems the right solution, if this is possible, why not to check
> for stuck TCP connections on resume?

The prospect is perhaps far-fetched, but the application could be in 
communication with another laptop, also in a long suspend, and 
initiating keepalive when the application did not request it could 
trigger a connection drop it was not otherwise expecting after the N 
keepalive probes were not answered (because the other end was 
suspended).  Of course, ostensibly such a connection should already be 
dealing with connection drop but still...

rick jones
