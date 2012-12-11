From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 04/10] net: smc911x: use io{read,write}*_rep
 accessors
Date: Tue, 11 Dec 2012 12:51:56 -0500 (EST)
Message-ID: <20121211.125156.1507794854679959729.davem@davemloft.net>
References: <1355166762-15133-5-git-send-email-will.deacon@arm.com>
	<20121210.154705.1773845547652835423.davem@davemloft.net>
	<20121211144949.GD16759@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	benh@kernel.crashing.org, arnd@arndb.de, james.hogan@imgtec.com,
	matthew@mattleach.net, netdev@vger.kernel.org
To: will.deacon@arm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20121211144949.GD16759@mudshark.cambridge.arm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Will Deacon <will.deacon@arm.com>
Date: Tue, 11 Dec 2012 14:49:49 +0000

> On Mon, Dec 10, 2012 at 08:47:05PM +0000, David Miller wrote:
>> This misses the two uses in smsc911x_tx_writefifo and
>> smsc911x_rx_readfifo.
> 
> Well spotted, updated patch below.

Although I'd like to take credit, the compiler told me :-)

> From b46e33465e755e945136d19938c9a8331cbafce7 Mon Sep 17 00:00:00 2001
> From: Matthew Leach <matthew@mattleach.net>
> Date: Tue, 6 Nov 2012 14:51:11 +0000
> Subject: [PATCH v3] net: smc911x: use io{read,write}*_rep accessors
> 
> The {read,write}s{b,w,l} operations are not defined by all
> architectures and are being removed from the asm-generic/io.h
> interface.
> 
> This patch replaces the usage of these string functions in the smc911x
> accessors with io{read,write}{8,16,32}_rep calls instead.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Matthew Leach <matthew@mattleach.net>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Applied, thanks.
