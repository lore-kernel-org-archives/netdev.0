From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] net: niu uses crc32, so select CRC32
Date: Thu, 10 Dec 2009 13:59:32 -0800
Message-ID: <20091210135932.b0774727.randy.dunlap@oracle.com>
References: <20091210175919.340b4c0c.sfr@canb.auug.org.au>
	<20091210093103.eda05dfe.randy.dunlap@oracle.com>
	<20091210.135138.263963420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091210.135138.263963420.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Dec 2009 13:51:38 -0800 (PST) David Miller wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Thu, 10 Dec 2009 09:31:03 -0800
> 
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > niu drivers uses crc32 functions, so it needs to select CRC32.
> > 
> > niu.c:(.text+0x18a7f8): undefined reference to `crc32_le'
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Applied, thanks Randy.
> 
> That dependency is quite indirect, it's due to ether_crc_*().
> I bet a quick grep for that will find several other drivers
> missing this Kconfig bit.

Yes, I've noticed that also...

---
~Randy
