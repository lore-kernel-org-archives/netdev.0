From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: L2 network namespace benchmarking (resend with Service Demand)
Date: Fri, 30 Mar 2007 09:30:24 -0600
Message-ID: <m1mz1uiwa7.fsf@ebiederm.dsl.xmission.com>
References: <460D1BBC.9090602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50884 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbXC3Pav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 11:30:51 -0400
In-Reply-To: <460D1BBC.9090602@fr.ibm.com> (Daniel Lezcano's message of "Fri,
	30 Mar 2007 16:16:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Hi,
>
> as suggested Rick, I added the Service Demand results to the matrix.

Thanks.  The latency number is interesting and it confirms what we were
seeing looking at cpu usage. 

We don't have an inexpesive way to get a packet from the outside world
to a network namespace.

Now if we can figure out why the routing code or the bridging code
seems to be performing extra packet copies, perhaps that can be fixed.

Eric
