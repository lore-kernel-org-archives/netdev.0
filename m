From: David Miller <davem@davemloft.net>
Subject: Re: NETROM: Fix use of static buffer
Date: Mon, 17 Aug 2009 18:05:45 -0700 (PDT)
Message-ID: <20090817.180545.235867598.davem@davemloft.net>
References: <20090817161636.GA26151@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090817161636.GA26151@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 17 Aug 2009 17:16:36 +0100

> The static variable used by nr_call_to_digi might result in corruption if
> multiple threads are trying to usee a node or neighbour via ioctl.  Fixed
> by having the caller pass a structure in.  This is safe because nr_add_node
> rsp. nr_add_neigh will allocate a permanent structure, if needed.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
