From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netdev: Octeon MGMT new driver + octeon_ethernet
 updates.
Date: Wed, 14 Oct 2009 01:09:13 -0700 (PDT)
Message-ID: <20091014.010913.21176323.davem@davemloft.net>
References: <4ACD1F4E.8090603@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4ACD1F4E.8090603@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed, 07 Oct 2009 16:07:58 -0700

> The main thrust of this patch set is to add a driver for the Cavium
> Networks Octeon processor's MII (Management port) Ethernet devices.
> Since it shares an mdio bus with the existing octeon-ethernet driver,
> there is also some rearrangement of that code.

Ralf how do you want to handle this patch set?

Since it's mostly MIPS infrastructure bits, please just add my:

Acked-by: David S. Miller <davem@davemloft.net>

to the commit that adds the actual driver under drivers/net/
and you can merge all of it via your tree.

Thanks!
