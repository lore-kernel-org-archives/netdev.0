From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP connection stops after high load.
Date: 12 Apr 2007 16:48:10 +0200
Message-ID: <p73y7kx7iol.fsf@bingen.suse.de>
References: <461D2DEA.4010806@candelatech.com>
	<461D447C.4070408@candelatech.com>
	<20070411.134804.50594117.davem@davemloft.net>
	<461D4DD7.7020207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:48246 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812AbXDLNt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 09:49:57 -0400
In-Reply-To: <461D4DD7.7020207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:
> 
> I don't mind adding printks...and I've started reading through the code,
> but there is a lot of it, and indiscriminate printks will likely just
> hide the problem because it will slow down performance so much.

You could add /proc/net/snmp counters for interesting events (e.g. GFP_ATOMIC
allocations failing). Perhaps netstat -s already shows something interesting.

-Andi
