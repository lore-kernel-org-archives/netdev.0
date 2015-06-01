From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vti6: Add pmtu handling to vti6_xmit.
Date: Mon, 01 Jun 2015 16:04:02 -0700 (PDT)
Message-ID: <20150601.160402.244453900846813301.davem@davemloft.net>
References: <5567695F.6070505@gmail.com>
	<20150529182709.2147.78230.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150529182709.2147.78230.stgit@ahduyck-vm-fedora22>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 29 May 2015 11:28:26 -0700

> From: Steffen Klassert <steffen.klassert@secunet.com>
> 
> We currently rely on the PMTU discovery of xfrm.
> However if a packet is localy sent, the PMTU mechanism
> of xfrm tries to to local socket notification what
> might not work for applications like ping that don't
> check for this. So add pmtu handling to vti6_xmit to
> report MTU changes immediately.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks Andrew.
