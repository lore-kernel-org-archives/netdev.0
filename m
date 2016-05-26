From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [RFC PATCH 0/7] tou: Transports over UDP - part I
Date: Thu, 26 May 2016 15:49:42 +0000 (UTC)
Message-ID: <loom.20160526T174601-63@post.gmane.org>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53218 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178AbcEZPt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 11:49:57 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1b5xXm-0006j9-Sv
	for netdev@vger.kernel.org; Thu, 26 May 2016 17:49:55 +0200
Received: from 66-87-139-205.pools.spcsdns.net ([66.87.139.205])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 17:49:54 +0200
Received: from eternaleye by 66-87-139-205.pools.spcsdns.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 17:49:54 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom <at> herbertland.com> writes:

> 
> Transports over UDP is intended to encapsulate TCP and other transport
> protocols directly and securely in UDP.
> 
> The goal of this work is twofold:
> 
> 1) Allow applications to run their own transport layer stack (i.e.from
>    userspace). This eliminates dependencies on the OS (e.g. solves a
>    major dependency issue for Facebook on clients).
> 
> 2) Make transport layer headers (all of L4) invisible to the network
>    so that they can't do intrusive actions at L4. This will be enforced
>    with DTLS in use.

Just popping in to note that this has significant similarities with the
DeDiS group's Tng project[1], which takes the approach of splitting the
"transport layer" into four sub-layers:

1.) Endpoint (What port?)
2.) Flow (Congestion control)
3.) Isolation (Integrity, confidentiality, and preventing middlebox mangling)
4.) Semantic (End-to-end guarantees, fate-sharing, stream vs. dgram vs.
seqpacket, etc)

[1] http://dedis.cs.yale.edu/2009/tng/
