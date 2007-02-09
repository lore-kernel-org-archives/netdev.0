From: Dan Malek <dan@embeddedalley.com>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
	generic iopa
Date: Fri, 9 Feb 2007 12:22:58 -0500
Message-ID: <6BD63E47-4738-4116-8A85-983D4FDCFBB9@embeddedalley.com>
References: <989B956029373F45A0B8AF02970818900D4401@zch01exm26.fsl.freescale.net>
	<17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
	<45CB270C.5090603@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <45CB270C.5090603@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Feb 8, 2007, at 8:35 AM, Timur Tabi wrote:

> That's what the original code did, kinda.  It called virt_to_phys() if
> it is main memory, and it called immrbar_virt_to_phys() if it is  
> MURAM.
>   immrbar_virt_to_phys() did pointer math to extract the physical  
> address.

You've got to be kidding.  You created yet another function
to determine the physical address from a virtual one! LOL!
Plus, you need logic in the code to first determine which
one to call?  Everyone is OK with this?


	-- Dan
