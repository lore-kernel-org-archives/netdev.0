From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 23:09:47 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520432DA91@orsmsx418.amr.corp.intel.com>
References: <200801151504.10047.elendil@planet.nl><20080115190458.rxt3yhb2o8o404kc@mail.bigtelecom.ru><36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com> <20080115.210214.170759690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <slavon@bigtelecom.ru>, <elendil@planet.nl>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4689 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778AbYAQHJt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 02:09:49 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080115.210214.170759690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
> Date: Tue, 15 Jan 2008 13:53:43 -0800
> 
>> The tx code has an "early exit" that tries to limit the amount of tx
>> packets handled in a single poll loop and requires napi or interrupt
>> rescheduling based on the return value from e1000_clean_tx_irq.
> 
> That explains everything, thanks Jesse.
> 
> Ok, here is the patch I'll propose to fix this.  The goal is to make
> it as simple as possible without regressing the thing we were trying
> to fix.

We spent Wednesday trying to reproduce (without the patch) these issues
without much luck, and have applied the patch cleanly and will continue
testing it.  Given the simplicity of the changes, and the community
testing, I'll give my ack and we will continue testing.

I think we should fix Robert's (unrelated, but in this thread) reported
issue before 2.6.24 final if we can, and I'll look at that tonight and
tomorrow.

Thanks for your work on this Dave,
 Jesse

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
