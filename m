From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
Date: Sat, 4 Feb 2017 13:54:29 -0800
Message-ID: <20170204135429.394be376@xeon-e3>
References: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, swise@opengridcomputing.com, jbenc@redhat.com,
 jmaxwell37@gmail.com, sean.hefty@intel.com, sthemmin@microsoft.com,
 sagi@grimberg.me, leon@kernel.org, Dept-GELinuxNICDev@cavium.com,
 dledford@redhat.com, ganeshgr@chelsio.com, harish.patil@cavium.com,
 hal.rosenstock@gmail.com, manish.chopra@cavium.com, santosh@chelsio.com,
 arnd@arndb.de, haiyangz@microsoft.com, fcoe-devel@open-fcoe.org,
 bart.vanassche@sandisk.com, jejb@linux.vnet.ibm.com, rahul.verma@cavium.com,
 linux-scsi@vger.kernel.org, martin.petersen@oracle.com, netdev@vger.kernel.org,
 devel@linuxdriverproject.org, varun@chelsio.com, linux-rdma@vger.kernel.org,
 monis@mellanox.com, valex@mellanox.com, QLogic-Storage-Upstream@qlogic.com,
 jth@kernel.org, davem@davemloft.net
To: Parav Pandit <parav@mellanox.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1486227649-12648-1-git-send-email-parav@mellanox.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Sat,  4 Feb 2017 11:00:49 -0600
Parav Pandit <parav@mellanox.com> wrote:

> This patch makes use of is_vlan_dev() function instead of flag
> comparison which is exactly done by is_vlan_dev() helper function.
> 
> Signed-off-by: Parav Pandit <parav@mellanox.com>
> Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
> ---
>  drivers/infiniband/core/cma.c                        |  6 ++----
>  drivers/infiniband/sw/rxe/rxe_net.c                  |  2 +-
>  drivers/net/ethernet/broadcom/cnic.c                 |  2 +-
>  drivers/net/ethernet/chelsio/cxgb3/l2t.c             |  2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  4 ++--
>  drivers/net/ethernet/chelsio/cxgb4/l2t.c             |  2 +-
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |  8 ++++----
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |  4 ++--
>  drivers/net/hyperv/netvsc_drv.c                      |  2 +-
>  drivers/scsi/bnx2fc/bnx2fc_fcoe.c                    |  6 +++---
>  drivers/scsi/cxgbi/libcxgbi.c                        |  6 +++---
>  drivers/scsi/fcoe/fcoe.c                             | 13 ++++++-------
>  include/rdma/ib_addr.h                               |  6 ++----
>  net/hsr/hsr_slave.c                                  |  3 ++-
>  14 files changed, 31 insertions(+), 35 deletions(-)

Looks good thanks.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
