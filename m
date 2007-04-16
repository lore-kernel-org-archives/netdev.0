From: Andi Kleen <andi@firstfloor.org>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: Mon, 16 Apr 2007 08:31:26 +0200
Message-ID: <20070416063126.GB14641@one.firstfloor.org>
References: <461FC32C.4060309@jwebb.sygneca.com> <1551EAE59135BE47B544934E30FC4FC09400A0@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie webb <j@jwebb.sygneca.com>, Andi Kleen <andi@firstfloor.org>,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59479 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbXDPGb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 02:31:27 -0400
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC09400A0@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That's right.  See the discussion on a similar problem here:
> 
> <http://forums1.itrc.hp.com/service/forums/questionanswer.do?threadId=10
> 59644&admit=-682735245+1158251313899+28353475>

That's an AMD machine.

> 
> In this other case, the symptoms were very similar to yours.
> I suspected it was an IOMMU problem, and the problem went
> away when the user upgraded to the latest kernel at that
> time.

tg3s never use the IOMMU on AMD systems with production kernels
because they have a suitably large DMA mask. IOMMU is only used
there to remap memory that doesn't fit a device's DMA mask.
There is a debugging mode to force iommu always, but it is not used 
unless you configure it specially.

-Andi
