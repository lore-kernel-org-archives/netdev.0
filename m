From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mmtree
Date: Mon, 8 Sep 2008 19:20:37 -0700
Message-ID: <B27EBC40D200ED48A3F4CC2EBEABAE0B1505CCBE@orsmsx501.amr.corp.intel.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org>
 <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
 <1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
 <200809032104.49092.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Qicheng Christopher Li <chrisl@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrey Borzenkov <arvidjaar@mail.ru>,
	Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbYIICVA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 22:21:00 -0400
In-Reply-To: <200809032104.49092.arvidjaar@mail.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8254x is not supported in e1000e however it is supported in e1000.  It is understandable that such a fix is needed (in e1000) for these older parts that did not have anyway of protecting EEPROM reads/writes as Jesse described in a previous email, but newer parts (supported in e1000e) have alternate methods of protection making the spinlock unnecessary.  There is no evidence the recent NVM/EEPROM corruptions on ICHx-based platforms (in e1000e) are due to the same issue resolved by the proposed fix used in VMware for 8254x parts.

I'm currently investigating this issue and hope to have something soon.

-----Original Message-----
From: Andrey Borzenkov [mailto:arvidjaar@mail.ru]
Sent: Wednesday, September 03, 2008 10:05 AM
To: Zachary Amsden
Cc: Brandeburg, Jesse; Qicheng Christopher Li; akpm@linux-foundation.org; Allan, Bruce W; jeff@garzik.org; Kirsher, Jeffrey T; Ronciak, John; Waskiewicz Jr, Peter P; netdev@vger.kernel.org
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mmtree

On Wednesday 03 September 2008, Zachary Amsden wrote:
> I'm sorry, we have no way to reproduce this, don't know anything about
> the hardware the customer was using

According to my information bug affects LAN controllers based on Intel 8254x GBe chipset. Of course, I do not claim it is exhaustive list.
