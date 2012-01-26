From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 02/10] bnx2x: Removing indirect register access
Date: Thu, 26 Jan 2012 21:50:08 +0000
Message-ID: <1327614608.2482.12.camel@bwh-desktop>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
	 <1327593714-18358-3-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, linux-pci <linux-pci@vger.kernel.org>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23048 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752735Ab2AZVuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:50:12 -0500
In-Reply-To: <1327593714-18358-3-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-26 at 18:01 +0200, Ariel Elior wrote:
> In virtualized environments indirect access to the device may not be supported
> (depending on the Hypervisor type). Indirect device access was used since in
> some harware contexts (i.e. certain chipset and BIOS) every access the driver
> makes across the pci is followed by a BIOS initiated Zero Length Read to the
> same address.
[...]

This is intriguing.  Isn't that a general problem that can affect many
devices?  Can you be more specific about which systems have this
behaviour?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
