From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 14 Aug 2012 19:19:58 +0000
Message-ID: <CAOZdJXUB7jLZ_p3TmOs+p=jQM4Xs0a=HUdFia5N46M--LYyXJg@mail.gmail.com>
References: <1344358266-5450-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "david.daney@cavium.com" <david.daney@cavium.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:48538
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753050Ab2HNTUE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2012 15:20:04 -0400
In-Reply-To: <1344358266-5450-1-git-send-email-timur@freescale.com>
Content-Language: en-US
Content-ID: <4F6FE6C59E59B644ABBBA83128B0A76A@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 7, 2012 at 11:51 AM, Timur Tabi <timur@freescale.com> wrote:
> The mdio-mux driver scans all child mdio nodes, without regard to whether
> the node is actually used.  Some device trees include all possible
> mdio-mux nodes and rely on the boot loader to disable those that are not
> present, based on some run-time configuration.  Those nodes need to be
> skipped.
>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---

Mr. Miller,

Any chance this patch can get into 3.6?  I don't know if it qualifies
as a fix or not, but getting it into 3.6 would make it easier for me
to apply other patches to the powerpc tree.

-- 
Timur Tabi
Linux kernel developer at Freescale
