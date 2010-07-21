From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Bugme-new] [Bug 16383] New: Regression with e1000e from
 2.6.34.1 to 2.6.35-rc5
Date: Wed, 21 Jul 2010 15:43:58 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FFE8449AA@rrsmsx501.amr.corp.intel.com>
References: <bug-16383-10286@https.bugzilla.kernel.org/>
 <20100721134843.f8b5b217.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"craig@haquarter.de" <craig@haquarter.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52830 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758595Ab0GUVoA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 17:44:00 -0400
In-Reply-To: <20100721134843.f8b5b217.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Andrew Morton
>Sent: Wednesday, July 21, 2010 1:49 PM
>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Duyck, Alexander
>H; Waskiewicz Jr, Peter P
>Cc: bugzilla-daemon@bugzilla.kernel.org; bugme-daemon@bugzilla.kernel.org;
>netdev@vger.kernel.org; craig@haquarter.de
>Subject: Re: [Bugme-new] [Bug 16383] New: Regression with e1000e from
>2.6.34.1 to 2.6.35-rc5
>
>
>(switched to email.  Please respond via emailed reply-to-all, not via the
>bugzilla web interface).
>
>On Wed, 14 Jul 2010 00:44:51 GMT
>bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=16383
>>
>>            Summary: Regression with e1000e from 2.6.34.1 to 2.6.35-rc5
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.35
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: high
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: craig@haquarter.de
>>         Regression: Yes
>>
>>
>> Created an attachment (id=27094)
>>  --> (https://bugzilla.kernel.org/attachment.cgi?id=27094)
>> .config
>>
>> Networking stops working with 2.6.35 (tested rc-3 and rc5).
>
>This is a post-2.6.34 regression, guys.  There's some more info in
>bugzilla.
>
>> # egrep "(e1000|eth)" dmesg-2.6.34.1
>> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
>> e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
>> e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
>> e1000e 0000:00:19.0: setting latency timer to 64
>> 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 5c:ff:35:02:2d:a9
>> 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
>> 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: a002ff-0ff
>> e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
>>
>> # egrep "(e1000|eth)" dmesg-2.6.35-rc5
>> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k4
>> e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
>> e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
>> e1000e 0000:00:19.0: setting latency timer to 64
>> e1000e 0000:00:19.0: (unregistered net_device): Failed to initialize MSI
>> interrupts.  Falling back to legacy interrupts.
>> e1000e 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1)
>5c:ff:35:02:2d:a9
>> e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
>> e1000e 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: a002ff-0ff
>> e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
>>
>> I hadn't set CONFIG_PCI_MSI but enabling it on 2.6.35-rc5 made no
>difference.

On what HW is this issue seen? Please provide the output of:
lspci -vvv
ethtool -e 
ethtool -S

kernel config.

Thanks,
Emil

