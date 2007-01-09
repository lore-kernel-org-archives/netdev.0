From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 10:26:02 +0100
Message-ID: <20070109092602.GC1703@ff.dom.local>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:32817 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751229AbXAIJYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 04:24:11 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05-01-2007 20:03, Thibaut VARENE wrote:
> Hi,
> 
> I've been experiencing this bug on my Pegasos II (PPC G4 1GHz, 512M
...
> [C7F6FA60] [C0012498] ret_from_except+0x0/0x14                                  
> --- Exception: 501 at __kmalloc+0x30/0xc0                                       
>     LR = rpc_malloc+0x48/0xac [sunrpc]                                          
> [C7F6FB20] [C3D72508] 0xc3d72508 (unreliable)                                   
> [C7F6FB30] [E2A88E18] rpc_malloc+0x48/0xac [sunrpc]                             
> [C7F6FB40] [E2A835F8] call_allocate+0x88/0x108 [sunrpc]                         
> [C7F6FB60] [E2A89554] __rpc_execute+0x94/0x248 [sunrpc]                         

Aren't there any other warnings displayed before?
No problems with memory or disk?

Regards,
Jarek P. 
