From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 13:11:13 -0700 (PDT)
Message-ID: <20071009.131113.112622864.davem@davemloft.net>
References: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
	<m1k5pwxjxd.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, xemul@openvz.org, devel@openvz.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752744AbXJIULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:11:13 -0400
In-Reply-To: <m1k5pwxjxd.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 09 Oct 2007 11:43:58 -0600

> David Stevens <dlstevens@us.ibm.com> writes:
> 
> > Sorry if this is a dumb question, but what is the model you intend for
> > SNMP? Do you want each namespace to be its own virtual machine with
> > its own, separate MIB?
> 
> Each network namespace appears to user space as a completely separate
> network stack.  So yes a separate instance of the MIB is appropriate.

We don't think you can validly do that, as David tried to explain.

The interface indexes are visible remotely to remote SNMP querying
applications.  They have to be unique within the physical system.
