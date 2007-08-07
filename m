From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9
 devices only)
Date: Tue, 07 Aug 2007 12:26:04 -0400
Message-ID: <46B89D1C.3060104@garzik.org>
References: <46B79934.8010405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, Andi Kleen <ak@suse.de>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42259 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762634AbXHGQ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 12:26:08 -0400
In-Reply-To: <46B79934.8010405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Mon, 6 Aug 2007 14:14:44 -0700
> Subject: [PATCH] e1000e: New pci-express e1000 driver (currently for 
> ICH9 devices only)
> 
> This driver implements support for the ICH9 on-board LAN ethernet
> device. The device is similar to ICH8.
> 
> The driver encompasses code to support 82571/2/3, es2lan and ICH8
> devices as well, but those device IDs are disabled and will be
> "lifted" from the e1000 driver over one at a time once this driver
> receives some more live time.
> 
> Changes to the last snapshot posted are exclusively in the internal
> hardware API organization. Many thanks to Jeff Garzik for jumping in
> and getting this organized with a keen eye on the future layout.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Thanks for posting the patch in a git-am friendly format :)

I merged this into netdev-2.6.git#e1000e just now, and pulled it into 
netdev-2.6.git#ALL so that Andrew's -mm tree will automatically pick up 
this driver.

Please submit e1000e in the form of follow-up patches to #e1000e, rather 
than reposting the entire driver.

We'll leave it on this side branch for a little while, to give others a 
chance to review and test, and give you (auke) a chance to update for 
Andi's comments etc.

	Jeff


