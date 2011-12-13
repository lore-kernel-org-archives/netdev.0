From: Udo Steinberg <udo@hypervisor.org>
Subject: Re: iwlagn regression in v3.1.5
Date: Tue, 13 Dec 2011 23:04:43 +0100
Message-ID: <20111213230443.2c12caeb@x220.fritz.box>
References: <4EE4AEF4.2080702@udo.edu>
	<4EE4DB55.4090804@udo.edu>
	<20111211174138.79e51fe8@x220.fritz.box>
	<4EE4E152.2070204@udo.edu>
	<1323627815.1806.19.camel@wwguy-ubuntu>
	<4EE50266.4050208@udo.edu>
	<1323653737.1806.21.camel@wwguy-ubuntu>
	<4EE636B9.1020305@udo.edu>
	<1323807327.7144.6.camel@wwguy-ubuntu>
	<4EE7BEC1.1060506@udo.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wwguy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:34395 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab1LMWFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 17:05:18 -0500
In-Reply-To: <4EE7BEC1.1060506@udo.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Glad to hear it works for you now. In the patch, the following piece of code

+				if ((iwl_is_associated_ctx(ctx) &&
+						!ctx->ht.is_40mhz) ||
+						!iwl_is_associated_ctx(ctx))

can be simplified to:

	if (!iwl_is_associated_ctx(ctx) || !ctx->ht.is_40mhz)

Cheers,

	- Udo

On Tue, 13 Dec 2011 22:08:17 +0100 Andrej Gelenberg (AG) wrote:

AG> Hi,
AG> 
AG> work now for me.
AG> 
AG> Regards,
AG> Andrej Gelenberg
AG> 
AG> On 12/13/2011 09:15 PM, wwguy wrote:
AG> > Hi Andrej,
AG> >
AG> > Could you try this patch and see any differences.
AG> >
AG> > please still use the same debug flag I ask you last time.
AG> >
AG> > Thanks
AG> > Wey
