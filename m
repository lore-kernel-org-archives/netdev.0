From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [patch for 2.6.27? 3/6] e1000: prevent corruption of EEPROM/NVM
Date: Fri, 19 Sep 2008 09:20:23 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520632F7B7@orsmsx418.amr.corp.intel.com>
References: <200809052104.m85L46VE020352@imap1.linux-foundation.org> <48D30335.1070908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <chrisl@vmware.com>, <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<pratap@vmware.com>, <zach@vmware.com>
To: "Jeff Garzik" <jeff@garzik.org>, <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40194 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbYISQUs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 12:20:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48D30335.1070908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> akpm@linux-foundation.org wrote:
>> From: Christopher Li <chrisl@vmware.com>
>> 
>> Andrey reports e1000 corruption, and that a patch in vmware's ESX
>> fixed it. 
>> 
>> The EEPROM corruption is triggered by concurrent access of the EEPROM
>> read/write. Putting a lock around it solve the problem.
>> 
>> [akpm@linux-foundation.org: use DEFINE_SPINLOCK to avoid confusing
>> lockdep] Signed-off-by: Christopher Li <chrisl@vmware.com>
>> Reported-by: Andrey Borzenkov <arvidjaar@mail.ru>
>> Cc: Zach Amsden <zach@vmware.com>
>> Cc: Pratap Subrahmanyam <pratap@vmware.com>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>> Cc: John Ronciak <john.ronciak@intel.com>
>> Cc: Jeff Garzik <jeff@garzik.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org> ---
>> 
>>  drivers/net/e1000/e1000_hw.c |   23 +++++++++++++++++++++++
>>  1 file changed, 23 insertions(+)
> 
> No further reply from Intel to my ping, and this regression needs to
> be addressed, so, applied.

My apologies Jeff.  I know it is late, but to close the loop, I agree
this is okay, in at least I don't believe it will harm anything, other
than adding un-necessary bloat at the worst.

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
