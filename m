From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v3 3/3] stmmac: pci: add MSI support for Intel Quark
 X1000
Date: Mon, 02 Feb 2015 17:46:27 +0200
Message-ID: <1422891987.31903.374.camel@linux.intel.com>
References: <54CF94FF.1050802@nexus-software.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	davem@davemloft.net, "Ahmad, Josef" <josef.ahmad@intel.com>
To: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:61567 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753092AbbBBPqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 10:46:25 -0500
In-Reply-To: <54CF94FF.1050802@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-02 at 15:17 +0000, Bryan O'Donoghue wrote:
> Hi guys.
> 
> Has the issue with PVM masking been addressed ?
> 
> https://lkml.org/lkml/2014/10/1/221
> 
> If not then please drop MSIs from this patchset.

I do not see the reason why it should be done on per driver basis.
Care to fix this under arch/x86 then when adding new Quark platform?

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
