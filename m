From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 10283] New: Ooops when bonding and vlan on the same device
Date: Wed, 19 Mar 2008 17:10:24 -0700
Message-ID: <8789.1205971824@death>
References: <bug-10283-10286@http.bugzilla.kernel.org/> <20080319140056.4eff6571.akpm@linux-foundation.org>
Cc: Ben Greear <greearb@candelatech.com>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	amartins@crefidis.fr
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37047 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936948AbYCTAKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 20:10:54 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2K0AjBM012316
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 20:10:45 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2K0Ai83221016
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 18:10:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2K0Ai0Y020527
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 18:10:44 -0600
In-reply-to: <20080319140056.4eff6571.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
[...]
>On Wed, 19 Mar 2008 05:19:34 -0700 (PDT)
>bugme-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=10283
>> 
>>            Summary: Ooops when bonding and vlan on the same device
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.18
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: low
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: amartins@crefidis.fr
>> 
>> 
>> Latest working kernel version: ?
>> Earliest failing kernel version: 2.6.18-6
>> Distribution: Debian
>> Hardware Environment: x86-686
>> Software Environment: stable release of Debian ETCH
>> Problem Description:
>> 
>> Ooops when adding a vlan on a device that is in slave mode of a bond device
>> (Sory for my english :)
>> 
>> Steps to reproduce:
>> 
>> modprobe bonding mode=1 miimon=100
>> ifconfig eth0 promisc up
>> ifenslave bond0 eth0
>> ifconfig bond0 up
>> vconfig add eth0 2 => Ooops
>> 
>
>Is a copy of the oops output available?
>
>Is there any possibility of testing a more up-to-date kernel?

	I don't see any errors when adding a VLAN approximately as
described above when running 2.6.25-rc4.  I say approximately because
the steps must be performed in a different order than shown, but adding
a VLAN to a slave that's up and promisc isn't generating an error for
me.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
