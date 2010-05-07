From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and mac-vlans problem
Date: Fri, 7 May 2010 11:40:29 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FEA6DBA5F@rrsmsx501.amr.corp.intel.com>
References: <4BDA07DB.8020206@candelatech.com>
 <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
 <4BDB57A6.1090400@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
 <4BE2ECEE.7070200@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0@rrsmsx501.amr.corp.intel.com>
 <4BE32B4A.2030409@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FEA26A969@rrsmsx501.amr.corp.intel.com>
 <4BE38502.2000507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62038 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825Ab0EGRkc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 13:40:32 -0400
In-Reply-To: <4BE38502.2000507@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 05/06/2010 05:06 PM, Tantilov, Emil S wrote:
>> Ben Greear wrote:
>>> On 05/06/2010 10:51 AM, Tantilov, Emil S wrote:
>>> 
>>>> Hi Ben,
>>>> 
>>>> We do have a patch in testing (see attached). It may not apply
>>>> cleanly as it is on top of some other patches currently in
>>>> validation. Let me know if it works for you.
>>> 
>>> It wasn't difficult to backport this patch to 2.6.31.12....
>>> 
>>> I just tested this on an 85998 NIC and 50 MAC-VLANs worked fine.
>>> 
>>> The NIC doesn't show as PROMISC in any way I can detect, but I guess
>>> it must actually be in PROMISC mode:
>> 
>> Yes the interface is in promisc mode. The driver sets the FCTRL.UPE
>> bit (unicast promisc mode) when the number of allowed rar_entries is
>> exceeded. 
> 
> Is there any way to get this setting from ethtool or similar?  It
> would be nice to know the actual PROMISC state of the NIC regardless of
> what user-space has or has not configured.

ethtool -d eth11 | grep -i promisc 

Thanks,
Emil

