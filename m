From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 11:43:58 -0600
Message-ID: <m1k5pwxjxd.fsf@ebiederm.dsl.xmission.com>
References: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>, devel@openvz.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48682 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbXJIRoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 13:44:32 -0400
In-Reply-To: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
	(David Stevens's message of "Tue, 9 Oct 2007 09:18:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> writes:

> Sorry if this is a dumb question, but what is the model you intend for
> SNMP? Do you want each namespace to be its own virtual machine with
> its own, separate MIB?

Each network namespace appears to user space as a completely separate
network stack.  So yes a separate instance of the MIB is appropriate.

Eric
