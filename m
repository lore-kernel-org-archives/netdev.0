From: david@lang.hm
Subject: Re: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 03:31:48 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712170327410.4467@asgard>
References: <20071217092401.GC4356@cs.unibo.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	garden@cs.unibo.it
To: Renzo Davoli <renzo@cs.unibo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-033-126.lax1.dsl.speakeasy.net ([64.81.33.126]:41896
	"EHLO bifrost.lang.hm" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932612AbXLQKVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:21:24 -0500
In-Reply-To: <20071217092401.GC4356@cs.unibo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007, Renzo Davoli wrote:

> Inter Process Networking (PATCH):
>
> 1. WHAT IS IPN?
> ---------------
>
> IPN is a new address family designed for one-to-many, many-to-many and
> peer-to-peer communication among processes.
> Berkeley sockets have been designed for client-server or point-to-point
> communication; AF_UNIX does not support multicast/broadcast. AF_IPN
> does, in a simple, efficient but extensible way.
> IPN is an Inter Process Communication paradigm where all the processes
> appear as they were connected by a networking bus.
>
> On IPN, processes can interoperate using real networking protocols
> (e.g. ethernet) but also using application defined protocols (maybe
> just sending ascii strings, video or audio frames, etc).
> IPN provides networking (in the broaden definition you can imagine) to
> the processes. Processes can be ethernet nodes, run their own TCP-IP stacks
> if they like (e.g. virtual machines), mount ATAonEthernet disks, etc.etc.
>
> IPN networks can be interconnected with real networks or IPN networks
> running on different computers can interoperate (can be connected by
> virtual cables).
>
> IPN is part of the Virtual Square Project (vde, lwipv6, view-os,
> umview/kmview, see wiki.virtualsquare.org).

other then the fact that this is bi-directional, how is this better then 
using pipes and splice?

wouldn't it be better to just add the ability for multiple writers to send 
to the same pipe, and then have all of them splice into the output of that 
pipe? this would give the same data-agnostic communication that you are 
looking for, and with the minor detail that software would have to filter 
out messages that they send, would appear to meet all the goals you are 
looking at, useing existing kernel features that are designed to be very 
high performance.

David Lang
