From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Wed, 08 Dec 2010 19:18:41 -0800
Message-ID: <m1ipz3d46m.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53293 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756829Ab0LIDSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 22:18:46 -0500
In-Reply-To: <m11v5rekg3.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 08 Dec 2010 18:42:04 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Playing with this some more I have come up with a totally evil testcase.
>
> If I bring lo down, and back up again I cannot talk to local addresses
> through the loopback device, that I could before.

I just tested 2.6.32.23 and I cannot ping local ipv6 addresses after
the loopback interface is brought administratively down and back up.

So it looks like we have some old bugs getting in the way an recent
changes that are reasonable.  I don't expect that it is by design
that bouncing the loopback interface breaks the ipv6 stack.

Eric
