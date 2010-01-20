From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Thu, 21 Jan 2010 00:59:20 +0100
Message-ID: <20100120235920.GF3072@del.dom.local>
References: <20100120.145218.259766536.davem@davemloft.net>
 <20100120232102.GD3072@del.dom.local>
 <20100120.153451.62650459.davem@davemloft.net>
 <20100120.154126.152942350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:52172 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294Ab0ATX7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:59:24 -0500
Received: by mail-fx0-f220.google.com with SMTP id 20so766930fxm.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 15:59:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100120.154126.152942350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 03:41:26PM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 20 Jan 2010 15:34:51 -0800 (PST)
> 
> > Whereas 1 patch in the 1 place in the DMA API implementation would fix
> > everything for everybody.
> 
> For the record I just checked DMAR and Intel-IOMMU and they
> don't even implement the SYNC ops, they are NULL and thus
> can't be effected by the changes being discussed here.
> 
> The generic DMA SYNC operations check for a NULL function
> pointer in the DMA operations, and do nothing if it is NULL.
> 
> Thus, so far it is proven that only the DMA debugging code 
> actually has this SYNC length requirement.

Thanks, I feel at least 75% safer ;-)

Good night!
Jarek P.
