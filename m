From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 11:27:59 +0100
Message-ID: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:47697 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbXAIK2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 05:28:01 -0500
Received: by ug-out-1314.google.com with SMTP id 44so6523696uga
        for <netdev@vger.kernel.org>; Tue, 09 Jan 2007 02:27:59 -0800 (PST)
To: "Jarek Poplawski" <jarkao2@o2.pl>
In-Reply-To: <20070109092602.GC1703@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> On 05-01-2007 20:03, Thibaut VARENE wrote:
> > Hi,
> >
> > I've been experiencing this bug on my Pegasos II (PPC G4 1GHz, 512M
> ...
> > [C7F6FA60] [C0012498] ret_from_except+0x0/0x14
> > --- Exception: 501 at __kmalloc+0x30/0xc0
> >     LR = rpc_malloc+0x48/0xac [sunrpc]
> > [C7F6FB20] [C3D72508] 0xc3d72508 (unreliable)
> > [C7F6FB30] [E2A88E18] rpc_malloc+0x48/0xac [sunrpc]
> > [C7F6FB40] [E2A835F8] call_allocate+0x88/0x108 [sunrpc]
> > [C7F6FB60] [E2A89554] __rpc_execute+0x94/0x248 [sunrpc]
>
> Aren't there any other warnings displayed before?

No, I've pasted the full dump that appeared on the serial console I
had setup when the crash occured.

> No problems with memory or disk?

I suspected both and changed both the disk and the ram for quality
parts, that I tested afterwards. Both passed thorough tests.

Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
works absolutely fine.

HTH

T-Bone

(PS: please CC me in answers)

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
