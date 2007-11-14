From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: BUG: sky2: hw csum failure with dual-port copper NIC on SMP
Date: Wed, 14 Nov 2007 10:37:10 -0500
Message-ID: <473B1626.20507@cybernetics.com>
References: <4739E425.20408@cybernetics.com>	<20071113141414.0959735a@freepuppy.rosehill>	<473A2BC8.7000909@cybernetics.com> <20071113152755.4d55c86a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host06.cybernetics.com ([206.246.200.22]:2668 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbXKNPhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 10:37:08 -0500
In-Reply-To: <20071113152755.4d55c86a@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> Do you want the test program I am using? It is a pretty basic
>> send()/recv() program, ~650 lines of C.
>>
>> Tony
>>
>>     
>
> Not really, iperf drives the problem fine.
>
>   

Thanks for the tip; I hadn't tried iperf before today.  I can reproduce
the problem with "iperf -s" on the system with the dual-port SysKonnect
NIC and "iperf -c host -t 120" on the two Intel PRO/1000 (e1000 driver)
client systems.  The problem doesn't seem to happen the other way around
though (running the server on the two Intel PRO/1000 systems and two
iperf clients on the SysKonnect system).  So the problem appears to be
triggered by recv() on the SysKonnect side but not send().

Tony

