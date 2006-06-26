From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Mon, 26 Jun 2006 10:40:59 -0600
Message-ID: <m1hd27uaxw.fsf@ebiederm.dsl.xmission.com>
References: <20060609210202.215291000@localhost.localdomain>
	<20060609210625.144158000@localhost.localdomain>
	<20060626134711.A28729@castle.nmd.msu.ru>
	<449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>
	<44A00215.2040608@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@swsoft.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	herbert@13thfloor.at, devel@openvz.org, sam@vilain.net,
	ebiederm@xmission.com, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:25999 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1750770AbWFZQmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 12:42:16 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <44A00215.2040608@fr.ibm.com> (Daniel Lezcano's message of "Mon,
	26 Jun 2006 17:49:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

>> Then you lose the ability for each namespace to have its own routing entries.
>> Which implies that you'll have difficulties with devices that should exist
>> and be visible in one namespace only (like tunnels), as they require IP
>> addresses and route.
>
> I mean instead of having the route tables private to the namespace, the routes
> have the information to which namespace they are associated.

Is this an implementation difference or is this a user visible difference?
As an implementation difference this is sensible, as it is pretty insane
to allocate hash tables at run time.

As a user visible difference that affects semantics of the operations
this is not something we want to do.

Eric
