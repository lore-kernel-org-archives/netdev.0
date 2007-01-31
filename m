From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/10] cxgb3 - Unmap offload packets when they are freed.
Date: Wed, 31 Jan 2007 05:41:57 -0500
Message-ID: <45C07275.9010501@garzik.org>
References: <20070131034424.8651.4713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, David Miller <davem@davemloft.net>
To: Divy Le Ray <None@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55620 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932969AbXAaKl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:41:58 -0500
In-Reply-To: <20070131034424.8651.4713.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Offload packets may be DMAed long after their SGE Tx descriptors are done
> so they must remain mapped until they are freed rather than until their
> descriptors are freed.  Unmap such packets through an skb destructor.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

this is questionable and sounds like you are working around a bug.  I 
can't think of another driver that uses skb destructors, and I could 
have sworn that skb destructors were not for drivers to use anyway

	Jeff


