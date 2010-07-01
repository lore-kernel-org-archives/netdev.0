From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Bugme-new] [Bug 16293] New: 82545GM in newest kernel not
 working.
Date: Thu, 1 Jul 2010 15:40:38 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF47D4E36@rrsmsx501.amr.corp.intel.com>
References: <bug-16293-10286@https.bugzilla.kernel.org/>
 <20100701140041.df2d147c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"lukas.valach@zoznam.sk" <lukas.valach@zoznam.sk>
To: Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42580 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933288Ab0GAVkl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 17:40:41 -0400
In-Reply-To: <20100701140041.df2d147c.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via
> the bugzilla web interface).
> 
> On Fri, 25 Jun 2010 17:48:43 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=16293
>> 
>>            Summary: 82545GM in newest kernel not working.           
>>            Product: Drivers Version: 2.5
>>     Kernel Version: 2.6.32.15
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: high
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: lukas.valach@zoznam.sk
>>         Regression: No
>> 
>> 
>> lspci:
>> 
>> 01:01.0 Ethernet controller: Intel Corporation 82545GM Gigabit
>> Ethernet Controller (rev 04) 01:02.0 Ethernet controller: Intel
>> Corporation 82545GM Gigabit Ethernet Controller (rev 04) 02:01.0
>> Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
>> Controller (rev 03) 02:01.1 Ethernet controller: Intel Corporation
>> 82546GB Gigabit Ethernet Controller (rev 03)  
>> 
>> All interface are correctly configured. In kernel <2.6.26 get all
>> OK, in newest kernels network interfaces are not working. Problem is
>> in driver e1000. Tested on 2.6.31,2.6.32,2.6.34 and 2.6.35rc.
> 
> A somewhat old e1000 regression?

I ran a quick test on net-next with 82545GM NICs and was able to pass traffic without issues.

Would it be possible to get more information about the system/setup:

1. full lspci output (lspci -vvv)
2. ethtool -i ethX
3. ethtool -d ethX
4. ethtool -e ethX
5. dmesg  - after loading the driver and configuring the interfaces
6. kernel config

A better description of the issue would help as well. What exactly fails - ping?

Thanks,
Emil