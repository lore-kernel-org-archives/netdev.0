From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 07/13] M68k HP Lance Ethernet: Fix leaks on
 probe/removal
Date: Wed, 24 Nov 2004 00:25:23 -0800
Message-ID: <20041124002523.219cef78.davem@davemloft.net>
References: <200411220644.iAM6i6900649@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200411220644.iAM6i6900649@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 22:43:54 -0800
akpm@osdl.org wrote:

> From: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> HP Lance Ethernet: There's tons of leaks in the hplcance probing code, and it
> doesn't release the memory region on removal either (from Christoph Hellwig)
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

This one looks like Jeff should review/merge it too.
