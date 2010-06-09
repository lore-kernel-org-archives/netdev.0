From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for June 9 (niu)
Date: Wed, 9 Jun 2010 10:36:57 -0700
Message-ID: <20100609103657.66252a27.randy.dunlap@oracle.com>
References: <20100609133443.38f1f957.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100609133443.38f1f957.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Jun 2010 13:34:43 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100608:
> 
> My fixes tree contains:
>       v4l-dvb: update gfp/slab.h includes
>       arm: update gfp/slab.h includes
>       davinci: update gfp/slab.h includes
>       ocfs2: update gfp/slab.h includes
>       acpi: update gfp/slab.h includes



on x86_64 or i386, CONFIG_OF_DEVICE is not enabled:

drivers/net/niu.c:9700: warning: 'struct of_device' declared inside parameter list
drivers/net/niu.c:9700: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/net/niu.c:9716: warning: assignment from incompatible pointer type

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
