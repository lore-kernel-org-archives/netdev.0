From: Christopher Li <chrisl@vmware.com>
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to
	-mmtree
Date: Tue, 2 Sep 2008 19:48:02 -0700
Message-ID: <20080903024801.GA26161@vmware.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com> <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com> <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zach Amsden <zach@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"arvidjaar@mail.ru" <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Pratap Subrahmanyam <pratap@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:41604 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbYICC4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 22:56:54 -0400
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2008 at 05:32:26PM -0700, Brandeburg, Jesse wrote:
> yes, since we issue a full reset and at least 2) above executes.  The
> corruption really shouldn't be writing to the eeprom in any way shape or
> form, but if it is we really need to fix the root cause of the bug, not
> just lock on either side of one of the cases which appears to cause the
> problem.
> 
> We are definitely investigating, please help us reproduce it if you can.

Sorry I am late to the discussion.

Can you try to have one process loop on reading the eeprom and
have another process loop on loading/unloading the e1000 driver?
That is the procedure we use in house to reproduce the bug and
verify the fix. It does not happen to every e1000 NICs. We need to
acquired the e1000 NICs from our customer who experienced the
problem. I am not surprised that there is some thing going on
with the hardware eeprom semaphore.

We just try to help when Andrew ask about this bug. I am not
a network driver developer either. Now you know as much as I
do, good luck with the repro. 

Chris

