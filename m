From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] net/core/pktgen.c shouldn't include pci.h
Date: Sat, 13 Nov 2004 23:18:02 -0800
Message-ID: <20041113231802.0704083e.davem@davemloft.net>
References: <20041113145351.GZ2249@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041113145351.GZ2249@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Nov 2004 15:53:51 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> If rebuilding after touching pci.h in 2.6, net/core/pktgen.c is the only 
> file under net/ that gets rebuilt.
> 
> I searched and didn't find any reason why net/core/pktgen.c needs to 
> include pci.h .
> 
> I'm therefore suggesting the patch below (applies against both 2.4
> and 2.6).

Yeah, that's pretty weird.  Patch applied, thanks Adrian :)
