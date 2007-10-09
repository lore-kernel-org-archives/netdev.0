From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 9 Oct 2007 09:18:25 -0700
Message-ID: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
References: <470B71CD.3000706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, devel@openvz.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43846 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbXJIQZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 12:25:09 -0400
In-Reply-To: <470B71CD.3000706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry if this is a dumb question, but what is the model you intend for
SNMP? Do you want each namespace to be its own virtual machine with
its own, separate MIB?

Ifindex's have to uniquely identify the interface (virtual or otherwise) 
to remote
queriers (not just local applications), so unless you pay the price of 
separating
all the SNMP MIBs per namespace too, it seems you'll need some way to
remap these for SNMP queries, right?

                                                +-DLS

