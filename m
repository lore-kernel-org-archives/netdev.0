From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [NET]: Allow partial checksums to be forwarded
Date: Mon, 26 Mar 2007 21:45:06 -0700
Message-ID: <4608A152.1060501@osdl.org>
References: <20070327043648.GA21558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38024 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933966AbXC0Ep0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 00:45:26 -0400
In-Reply-To: <20070327043648.GA21558@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Dave:
>
> Looks like I forgot to finish the checksum stuff for Xen last time around.
>
> [NET]: Allow partial checksums to be forwarded
>
> Right now Xen has a horrible hack that lets it forward packets with
> partial checksums.  One of the reasons that CHECKSUM_PARTIAL was added
> is so that we can get rid of this hack (where it creates an extra bit
> in the skbuff to essentially mirror ip_summed without being destroyed
> by the forwarding code).
>
> So here is the patch that lets us get rid of the hack by preserving
> CHECKSUM_PARTIAL on forwarded packets.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers,
>   

Looks okay.
