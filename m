From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.27
Date: Thu, 17 Jul 2008 10:31:47 +0300
Message-ID: <487EF563.9090102@voltaire.com>
References: <ada8ww5jbaf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada8ww5jbaf.fsf@cisco.com>
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
> ... 2.6.26 is already out, so it's time to review what my plans are for the merge window opens.
>
> Core:
>
>  - I'm waiting to merge the RDMA_CM_EVENT_ADDR_CHANGE changes that
>    depend on core networking changes until such changes are upstream.
>    Or, please remind me when that happens.
Dave,

There are some rdma patches for 2.6.27 which are dependent on few 
networking patches (below), so Roland can't push them before the net 
changes gets in, such that enough time has to be left for the rdma push 
before the merge window closes...

Or.
> commit 01f3109de49a889db8adf9116449727547ee497e
> Author: Or Gerlitz <ogerlitz@voltaire.com>
> Date:   Fri Jun 13 18:12:02 2008 -0700
>
>     bonding: deliver netdev event for fail-over under the active-backup mode
>
> commit 709f8a45e8521f2f4229e5fdf3ded1fb77e2ca4e
> Author: Or Gerlitz <ogerlitz@voltaire.com>
> Date:   Fri Jun 13 18:12:01 2008 -0700
>
>     bonding: bond_change_active_slave() cleanup under active-backup
>
> commit c1da4ac752b8b0411791d26c678fcf23d2eed242
> Author: Or Gerlitz <ogerlitz@voltaire.com>
> Date:   Fri Jun 13 18:12:00 2008 -0700
>
>     net/core: add NETDEV_BONDING_FAILOVER event
