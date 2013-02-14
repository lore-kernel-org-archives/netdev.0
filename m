From: Rick Jones <rick.jones2@hp.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Thu, 14 Feb 2013 11:42:39 -0800
Message-ID: <511D3E2F.3080408@hp.com>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain> <511ADEBB.1000701@genband.com> <kfi5k6$1mq$1@ger.gmane.org> <511D141B.602@genband.com> <23692.1360864993@death.nxdomain> <511D3AFC.10504@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:37502 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758666Ab3BNTml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 14:42:41 -0500
In-Reply-To: <511D3AFC.10504@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a VM were to see its link to the bridge module bounce/cycle, might 
that cause it to send a gratuitous ARP on its own?  It would be 
something akin to the "if this uplink fails, bring down these downlinks" 
functionality that is out there in some places.  Bond says "hey, I've 
had a change" then bridge toggles the "downlinks" to the VMs.

rick jones
