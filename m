From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on
 Supermicro X7DB3
Date: Wed, 8 Oct 2008 23:36:30 +0200
Message-ID: <20081008233630.53d26853@speedy>
References: <EA929A9653AAE14F841771FB1DE5A1365F498F4EDC@rrsmsx501.amr.corp.intel.com>
	<E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Hillier, Gernot "
	<IMCEAMAILTO-gernot+2Ehillier+40siemens+2Ecom@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Hockert, Jeff W" <jeff.w.hockert@intel.com>,
	"Graham, David" <david.graham@intel.com>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54419 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756888AbYJHVgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:36:39 -0400
In-Reply-To: <E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Oct 2008 08:25:49 -0700
"Graham, David" <david.graham@intel.com> wrote:

> Hi Gernot,
> 
> Thanks for reporting this issue. We have witnessed this in our labs too,
> only on platforms that have BMC management firmware. I'm very familiar
> with the problem, and believe that we have fixed it, though the
> application of the fix may not be simple. The problem is a result of
> improper synchronization between the platform FW and the e1000e driver
> when they attempt concurrent access to LAN resources, and fixes were
> made both on the driver side, and on the FW side. On some platforms a
> simple driver update resolves the problem, others require FW fixes too.
> 
> The 0.2.0 driver in 2.6.25 has no fixes for this problem, and so I am
> not surprised that you see it there. The first set of changes for this
> issue are already in the 0.3.3.3-k2 driver that you are still seeing the
> problem with on 2.6.26, so either those changes are not good, or your
> issue requires one of the additional fixes.
> 
> There have been further improvements made to the driver synchronization
> code since the 0.3.3.3-k2 driver, and it is possible that a newer driver
> would resolve the issue. It'd be good for us to know if that's the case.
> The driver version is not yet (AFAICS) upstream, but is already
> available in the standalone e1000e-0.4.1.7 driver on sourceforge.
> (google "sourceforge e1000e"). Would you be able to try that, as a first
> step ? 

Repeat rant heard from many users and vendors:
  Why does Intel continue to not do driver development in mainline kernel?
 
