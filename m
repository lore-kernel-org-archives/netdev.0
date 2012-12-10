From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 06/10] net: 8390: use io{read,write}*_rep accessors
Date: Mon, 10 Dec 2012 15:47:37 -0500 (EST)
Message-ID: <20121210.154737.1161137982809830125.davem@davemloft.net>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
	<1355166762-15133-7-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	benh@kernel.crashing.org, arnd@arndb.de, james.hogan@imgtec.com,
	matthew@mattleach.net, netdev@vger.kernel.org
To: will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355166762-15133-7-git-send-email-will.deacon@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Will Deacon <will.deacon@arm.com>
Date: Mon, 10 Dec 2012 19:12:38 +0000

> From: Matthew Leach <matthew@mattleach.net>
> 
> The {read,write}s{b,w,l} operations are not defined by all
> architectures and are being removed from the asm-generic/io.h
> interface.
> 
> This patch replaces the usage of these string functions in the 8390
> accessors with io{read,write}{8,16,32}_rep calls instead.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Matthew Leach <matthew@mattleach.net>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Applied.
