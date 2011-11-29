From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] NET: NETROM: When adding a route verify length of
 mnemonic string.
Date: Tue, 29 Nov 2011 01:18:02 -0500 (EST)
Message-ID: <20111129.011802.843346730815178441.davem@davemloft.net>
References: <cover.1322214950.git.ralf@linux-mips.org>
	<cfff1df64b18a89140ff995189c6a3c484815997.1322214950.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	dan.carpenter@oracle.com, wharms@bfs.de, thomas@osterried.de
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cfff1df64b18a89140ff995189c6a3c484815997.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 25 Nov 2011 09:08:49 +0000

> struct nr_route_struct's mnemonic permits a string of up to 7 bytes to be
> used.  If userland passes a not zero terminated string to the kernel adding
> a node to the routing table might result in the kernel attempting to read
> copy a too long string.
> 
> Mnemonic is part of the NET/ROM routing protocol; NET/ROM routing table
> updates only broadcast 6 bytes.  The 7th byte in the mnemonic array exists
> only as a \0 termination character for the kernel code's convenience.
> 
> Fixed by rejecting mnemonic strings that have no terminating \0 in the first
> 7 characters.  Do this test only NETROM_NODE to avoid breaking NETROM_NEIGH
> where userland might passing an uninitialized mnemonic field.
> 
> Initial patch by Dan Carpenter <dan.carpenter@oracle.com>.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
