From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
	quirk
Date: Mon, 17 Nov 2008 20:12:11 +0000
Message-ID: <1226952732.3014.33.camel@achroite>
References: <20081116.191252.80669091.davem@davemloft.net>
	 <4921C8B0.9060301@redhat.com>
	 <20081117.114952.81357471.davem@davemloft.net>
	 <B27EBC40D200ED48A3F4CC2EBEABAE0B238BF6E9@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"csnook@redhat.com" <csnook@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49146 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751681AbYKQUMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 15:12:15 -0500
In-Reply-To: <B27EBC40D200ED48A3F4CC2EBEABAE0B238BF6E9@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-17 at 12:02 -0800, Allan, Bruce W wrote:
[...]
> Once the NVRAM is write-protected the driver cannot revoke that
> protection, only a system reset will do that.  The kernel command line
> option to disable the write protection is so that if/when a user needs
> to change a value in the NVRAM it can still be done.

Although the ICHx write-protection bit is irreversible without a reset,
it works with SPI flash chips and these normally have their own write-
protection bits that can be switched on and off.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

