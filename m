From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [patch for 2.6.27? 4/4] e1000e: prevent corruption of EEPROM/NVM
Date: Tue, 2 Sep 2008 15:01:28 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52060519E7@orsmsx418.amr.corp.intel.com>
References: <200809022148.m82LmKQu014384@imap1.linux-foundation.org>
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
To: <akpm@linux-foundation.org>, <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40856 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbYIBWBa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 18:01:30 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200809022148.m82LmKQu014384@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Christopher Li <chrisl@vmware.com>
> 
> Andrey reports e1000e corruption, and that a patch in vmware's ESX
> fixed 
> it.
> 
> The EEPROM corruption is triggered by concurrent access of the EEPROM
> read/write. Putting a lock around it solve the problem.
> 

NAK.  Please do not apply this patch, for reasons mentioned in my other
reply just sent to netdev.

The RTNL should be preventing this from being a possible bug in *Linux*
and if it is not we have much larger problems, not the least of which is
that this patch doesn't lock against the driver accessing the eeprom
simultaneously.
