From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Raylink/WebGear testing - ray_cs.c iomem bug?
Date: Wed, 6 Oct 2004 10:56:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0410061053550.8290@ppc970.osdl.org>
References: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Corey Thomas <corey@world.std.com>
In-Reply-To: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Oct 2004, Linus Torvalds wrote:
> 
> If somebody has access to this card and can test it, can you email me? I'd 
> hate to apply even an "obvious" fix when the bug may be hidden by other 
> bugs, and the obvious fix might end up breaking things for silly reasons.

Ahh. Never mind. It looks like the RCS/CCS difference is encoded in the 
index that is used to offset the base, which means that rcs_base and 
ccs_base really do end up being the same thing.

Still, I'd love to have somebody verify that the cleaned-up version 
(without any changes) still works. It should be 100% equivalent to the old 
one, but it's good to make sure.

		Linus
