From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 4/4] e1000e: prevent corruption of EEPROM/NVM
Date: Sat, 13 Sep 2008 15:15:02 -0400
Message-ID: <48CC1136.2090005@garzik.org>
References: <200809022148.m82LmKQu014384@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F52060519E7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	chrisl@vmware.com, arvidjaar@mail.ru,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	pratap@vmware.com, zach@vmware.com
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36751 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbYIMTPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:15:09 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52060519E7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> akpm@linux-foundation.org wrote:
>> From: Christopher Li <chrisl@vmware.com>
>>
>> Andrey reports e1000e corruption, and that a patch in vmware's ESX
>> fixed 
>> it.
>>
>> The EEPROM corruption is triggered by concurrent access of the EEPROM
>> read/write. Putting a lock around it solve the problem.
>>
> 
> NAK.  Please do not apply this patch, for reasons mentioned in my other
> reply just sent to netdev.
> 
> The RTNL should be preventing this from being a possible bug in *Linux*
> and if it is not we have much larger problems, not the least of which is
> that this patch doesn't lock against the driver accessing the eeprom
> simultaneously.

Ping.  A problem still occurs, regardless of what should be prevented?


