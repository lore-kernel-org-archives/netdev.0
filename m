From: sreeniva@cse.psu.edu
Subject: Re: Labeled IPsec with NAT
Date: Wed, 12 Dec 2007 01:10:23 -0500 (EST)
Message-ID: <3205.64.178.102.202.1197439823.squirrel@www.cse.psu.edu>
References: <200712120503.lBC53AYb028820@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sreeniva@cse.psu.edu, netdev@vger.kernel.org
To: "Joy Latten" <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from psuvax1.cse.psu.edu ([130.203.4.6]:48519 "EHLO mail.cse.psu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbXLLGKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 01:10:33 -0500
In-Reply-To: <200712120503.lBC53AYb028820@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joy,

>>I am working on setting up Labeled IPsec along with iptables nat
>>rules. Once I insert nat related rules, the ipsec connection breaks
>>and the system tries to re-negotiate and creates multiple SAs. I am
>>using 2.6.19 kernel (with Venkat's MLSXFRM patches & bugfixes). I
>>guess those were incorporated into the 2.6.20 kernel.
>
> Are you using racoon in ipsec-tools to create labeled SAs?
> If so, I recall seeing duplicate SA pairs being created
> while using racoon for labeled ipsec. We determined userspace
> should manage this.
> I posted a patch to ipsec-tools, but I don't think they
> ever picked it up... I do not know if this is same problem,
> but you could give it a try.

Thanks for replying. I am using racoon for testing. I searched for your
patch in the ipsec-tools, but couldn't find it. It would be helpful if you
could point me to the patch.

The reason I was debugging the kernel is because I was under the
assumption that the kernel should not invoke racoon if a matching SA is
available in the SAD (like in my case).

Thanks
Yogesh

