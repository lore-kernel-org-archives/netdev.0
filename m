From: Tziporet Koren <tziporet@dev.mellanox.co.il>
Subject: Re: [ofa-general][PATCH 2/2] mlx4: ConnectX multi functional device
	support
Date: Sun, 05 Jul 2009 11:10:13 +0300
Message-ID: <4A505FE5.4040108@mellanox.co.il>
References: <4A3A34F5.9030800@mellanox.co.il>	<4A4C816A.2040506@mellanox.co.il>
	<adabpo317c5.fsf@cisco.com>	<4A4CD0D7.6070409@mellanox.co.il>
	<ada7hyr10do.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada7hyr10do.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  
> Well, I need to think over the patch a little more.  The risk is
> certainly not zero, since we are changing device initialization for all
> mlx4 devices.  And I'm not sure if missing 2.6.31 support is that big a
> deal for you, is it?  How many users do you have building their own
> upstream kernels?  You're just going to tell everyone to use OFED
> anyway, right?
>   
This is NOT related to OFED at all. This is our 10G NIC driver. See the 
description:

/* MT26468 ConnectX EN 10GigE, PCIe, 2.0 5Gt/s */

We have several customer that take our 10G driver from kernel.org, and 
once the HW is out we will have a problem.
Also to include this code in next Redhat & Novell updates we need to 
have it in the kernel too.

I know the risk is not zero, but you must admit its not high either, and 
we already tested it here thoroughly here with all device IDs
Since we sent the patches on time for inclusion not clear why they are 
being declined now.
Please see what can be done.

Thanks,
Tziporet
