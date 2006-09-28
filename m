From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration changes
Date: Thu, 28 Sep 2006 17:25:14 -0400
Message-ID: <451C3DBA.9040007@hp.com>
References: <20060928180326.896170000@hp.com> <20060928180337.570612000@hp.com> <Pine.LNX.4.64.0609281547060.28120@d.namei> <451C2AEA.7050608@hp.com> <Pine.LNX.4.64.0609281609560.28355@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-audit@redhat.com, Eric Paris <eparis@redhat.com>,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:8922 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161181AbWI1VZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 17:25:16 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609281609560.28355@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Thu, 28 Sep 2006, Paul Moore wrote:
> 
>>Agreed, in fact, as I suspect you have already noticed, this was ripped
>>right from that function.  It was private to kernel/auditsc.c making it
>>offlimits, but I would have gladly used it instead; making
>>audit_log_task_info() public seemed like something that was beyond this
>>NetLabel specific patch.
> 
> Don't ever be afraid to improve core kernel code :-)

Okay, I just added it to my todo list.

-- 
paul moore
linux security @ hp
