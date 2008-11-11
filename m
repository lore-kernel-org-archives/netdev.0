From: "Hillier, Gernot" <gernot.hillier@siemens.com>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro
 X7DB3
Date: Tue, 11 Nov 2008 11:05:23 +0100
Message-ID: <491958E3.1030501@siemens.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F498F4EDC@rrsmsx501.amr.corp.intel.com> <E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com> <48EE04C0.6070504@siemens.com> <48F463D1.70605@siemens.com> <E3627BC91D010645BD262A1E8720005106B67989@orsmsx420.amr.corp.intel.com> <48F766CB.3030603@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Hockert, Jeff W" <jeff.w.hockert@intel.com>
To: "Graham, David" <david.graham@intel.com>,
	"Fodor, Zoltan" <zoltan.fodor@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:16672 "EHLO david.siemens.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299AbYKKJ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 04:59:32 -0500
In-Reply-To: <48F766CB.3030603@siemens.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Dave,

On 2008-10-16, Hillier, Gernot wrote:
> Hi there!
> 
> Graham, David wrote:
>> It would help if you could provide a little more information. Could you
>> provide (for one of each of the two configurations that you have - one
>> with the IPMI card, one without):
>>
>> 	lspci -t
>> 	lspci -vvv -xxxx
>> 	ethtool -e eth0
> 
> Ok, it turned out that we still can reproduce the problem - even after the
> firmware upgrade. So I collected the information you requested from two
> machines:

Wanted to let you know that this problem seems to be fixed for us.

We received a preliminary update from Supermicro which contains a new NIC
firmware 2.5 they recently received from your side with improved Shared LAN
support (56313.eep, release date 2008-10-01) .

After flashing this update together with a new BMC card firmware 1.59, the
problem has finally vanished for us. (For some reason, only updating the
NIC firmware wasn't possible, so we can't unfortunately nail down which
update part really fixed the problem.)

1.5 days of an rmmod/insmod loop and 2.5 days of a complete OS reboot loop
now have been passed w/o problems. Both tests triggered the problem
reliably within at most one day before.

So thanks again for your help!

-- 
With kind regards,

Gernot Hillier
Siemens AG, Corporate Competence Center Embedded Linux
