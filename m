From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Fri, 03 Jul 2015 09:47:04 -0700 (PDT)
Message-ID: <20150703.094704.283183007204034386.davem@davemloft.net>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbbGCQrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:47:05 -0400
In-Reply-To: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Thu, 2 Jul 2015 18:21:24 -0700

> This is a request for comments.
> 
> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier version of
> NV was presented at 2010's LPC (slides). It is a delayed based
> congestion avoidance for the data center. This version has been tested
> within a 10G rack where the HW RTTs are 20-50us.
> 
> A description of TCP-NV, including implementation and experimental
> results, can be found at:
> http://www.brakmo.org/networking/tcp-nv/TCPNV.html
> 
> The current version includes many module parameters to support
> experimentation with the parameters.
> 
> Signed-off-by: Lawrence Brakmo <lawrence@brakmo.org>

I'm disappointed in the skb->cb[] size increase, like Eric.  This
severely negatively impacts everyone on every Linux system in the
world, not just people using NV.

The performance implications from increasing sk_buff by even 1 byte in
size are absolutely non-trivial.
