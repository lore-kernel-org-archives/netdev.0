From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [Bugme-new] [Bug 9808] New: system hung with htb QoS
Date: Fri, 1 Feb 2008 09:36:10 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520452C44F@orsmsx418.amr.corp.intel.com>
References: <bug-9808-10286@http.bugzilla.kernel.org/> <20080124061157.3512a308.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bilias@edu.physics.uoc.gr>, <bugme-daemon@bugzilla.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35781 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbYBARg7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 12:36:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080124061157.3512a308.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> On Thu, 24 Jan 2008 03:03:11 -0800 (PST)
>> bugme-daemon@bugzilla.kernel.org wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=9808 
>> 
>>            Summary: system hung with htb QoS
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.23.9
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Fedora
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Netfilter/Iptables
>>         AssignedTo:
>>         networking_netfilter-iptables@kernel-bugs.osdl.org
>> ReportedBy: bilias@edu.physics.uoc.gr 

This user was able to eliminate the tx hang problem with htb QoS by
disabling TSO.  We also have some reports of xen hangs when TSO is
enabled as well.  Not sure if they are related.

At this point this user has a workaround.  We will continue to try to
reproduce here to see if we can root cause the hardware issue, but we
haven't had any luck so far.
