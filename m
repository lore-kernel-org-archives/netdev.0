From: Brian Haley <brian.haley@hp.com>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26,	ip6_route_output,
 rt6_fill_node+0x175
Date: Mon, 11 Aug 2008 20:41:22 -0400
Message-ID: <48A0DC32.9030309@hp.com>
References: <9F6ACAE02B6DD040A1E259977622CFDB033590C3@oslexcp1.eu.tandberg.int> <20080807203748.GA5196@martell.zuzino.mipt.ru> <489BD227.6000209@hp.com> <20080811110335.GA29407@kernel.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	John Gumb <john.gumb@tandberg.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eugene Teo <eugeneteo@kernel.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:21252 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbYHLAlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:41:25 -0400
In-Reply-To: <20080811110335.GA29407@kernel.sg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Teo wrote:
> I think it's better to use a helper routine like ipv6_get_saddr to make
> sure that both dst and rt6i_idev arguments are checked for NULL.
> 
> I have compiled, and tested the patch.
> 
> Thanks,
> Eugene
> 
> ---
> Fix NULL pointer dereference in rt6_fill_node().
> 
> # ip -f inet6 route get fec0::1
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000
> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
> EIP is at rt6_fill_node+0x175/0x3b0
> 
> Cc: Stable <stable@kernel.org>
> Signed-off-by: Eugene Teo <eugeneteo@kernel.sg>

Acked-by: Brian Haley <brian.haley@hp.com>

But Yoshfuji might have another opinion since he did the work to remove 
ipv6_get_saddr() in the first place.

-Brian
