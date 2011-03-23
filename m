From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: davinci_emac:Fix translation logic for buffer
 descriptor
Date: Tue, 22 Mar 2011 19:25:16 -0700 (PDT)
Message-ID: <20110322.192516.260072341.davem@davemloft.net>
References: <1300797063-13558-1-git-send-email-srk@ti.com>
	<B85A65D85D7EB246BE421B3FB0FBB593024C47D8B1@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srk@ti.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	sshtylyov@mvista.com
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754621Ab1CWCYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 22:24:38 -0400
In-Reply-To: <B85A65D85D7EB246BE421B3FB0FBB593024C47D8B1@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nori, Sekhar" <nsekhar@ti.com>
Date: Tue, 22 Mar 2011 20:10:01 +0530

> On Tue, Mar 22, 2011 at 18:01:03, Govindarajan, Sriramakrishnan wrote:
>> With recent changes to the driver(switch to new cpdma layer),
>> the support for buffer descriptor address translation logic
>> is broken. This affects platforms where the physical address of
>> the descriptors as seen by the DMA engine is different from the
>> physical address.
>> 
>> Original Patch adding translation logic support:
>> Commit: ad021ae8862209864dc8ebd3b7d3a55ce84b9ea2
>> 
>> Signed-off-by: Sriramakrishnan A G <srk@ti.com>
>> ---
>> Addresses review comments from Sergei. Generated against tip of Linus tree.
> 
> Just tested this patch on DM6446 EVM. Successfully
> tried an NFS boot.
> 
> Tested-By: Sekhar Nori <nsekhar@ti.com>

Patch applied, thanks everyone.
