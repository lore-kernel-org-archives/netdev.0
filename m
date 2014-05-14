From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}: Multiple transmit and receive queues
Date: Wed, 14 May 2014 16:09:23 +0200
Message-ID: <526369072.20140514160923@eikelenboom.it>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, davem@davemloft.net,
	wei.liu2@citrix.com, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <paul.durrant@citrix.com>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:44848 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbaENOJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 10:09:28 -0400
In-Reply-To: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, May 14, 2014, 3:52:24 PM, you wrote:

> This patch series implements multiple transmit and receive queues (i.e.
> multiple shared rings) for the xen virtual network interfaces.

> The series is split up as follows:
>  - Patch 1 brings the 'grant_copy_op' array back into struct xenvif, in
>    preparation for multi-queue support. See the patch itself for more details.
> - Patches 2 and 4 factor out the queue-specific data for netback and
>   netfront respectively, and modify the rest of the code to use these
>   as appropriate.
> - Patches 3 and 5 introduce new XenStore keys to negotiate and use
>   multiple shared rings and event channels, and code to connect these
>   as appropriate.
> - Patch 6 documents the XenStore keys required for the new feature
>   in include/xen/interface/io/netif.h

> All other transmit and receive processing remains unchanged, i.e. there
> is a kthread per queue and a NAPI context per queue.

> The performance of these patches has been analysed in detail, with
> results available at:

<snip>

Would it be possible to also put these somewhere in a tree (or branch of the 
xen-tree), so it is more easy to pull and test ?

--
Sander

> --
> Andrew J. Bennieston
