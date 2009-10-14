From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mmotm] net: ks8851_mll uses mii interfaces
Date: Wed, 14 Oct 2009 15:11:06 -0700 (PDT)
Message-ID: <20091014.151106.138362225.davem@davemloft.net>
References: <200910140436.n9E4aF9G001644@imap1.linux-foundation.org>
	<20091014145905.219416bb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, david.choi@micrel.com
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762049AbZJNWLM@vger.kernel.org>
In-Reply-To: <20091014145905.219416bb.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 14 Oct 2009 14:59:05 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> ks8851_mll uses mii interfaces so it needs to select MII.
> 
> ks8851_mll.c:(.text+0xf95ac): undefined reference to `generic_mii_ioctl'
> ks8851_mll.c:(.text+0xf96a0): undefined reference to `mii_ethtool_gset'
> ks8851_mll.c:(.text+0xf96fa): undefined reference to `mii_ethtool_sset'
> ks8851_mll.c:(.text+0xf9754): undefined reference to `mii_link_ok'
> ks8851_mll.c:(.text+0xf97ae): undefined reference to `mii_nway_restart'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: David Choi <david.choi@micrel.com>

Applied, thanks Randy.
