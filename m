From: "Nori, Sekhar" <nsekhar@ti.com>
Subject: RE: [PATCHv2] net: davinci_emac:Fix translation logic for buffer
	descriptor
Date: Tue, 22 Mar 2011 20:10:01 +0530
Message-ID: <B85A65D85D7EB246BE421B3FB0FBB593024C47D8B1@dbde02.ent.ti.com>
References: <1300797063-13558-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sshtylyov@mvista.com" <sshtylyov@mvista.com>
To: "Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:33634 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab1CVOkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 10:40:15 -0400
In-Reply-To: <1300797063-13558-1-git-send-email-srk@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 18:01:03, Govindarajan, Sriramakrishnan wrote:
> With recent changes to the driver(switch to new cpdma layer),
> the support for buffer descriptor address translation logic
> is broken. This affects platforms where the physical address of
> the descriptors as seen by the DMA engine is different from the
> physical address.
> 
> Original Patch adding translation logic support:
> Commit: ad021ae8862209864dc8ebd3b7d3a55ce84b9ea2
> 
> Signed-off-by: Sriramakrishnan A G <srk@ti.com>
> ---
> Addresses review comments from Sergei. Generated against tip of Linus tree.

Just tested this patch on DM6446 EVM. Successfully
tried an NFS boot.

Tested-By: Sekhar Nori <nsekhar@ti.com>

Thanks,
Sekhar

