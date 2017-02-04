From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net-next: treewide use is_vlan_dev() helper function.
Date: Fri, 03 Feb 2017 21:10:45 -0800
Message-ID: <1486185045.22276.79.camel@perches.com>
References: <1486182386-50797-1-git-send-email-parav@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Parav Pandit <parav@mellanox.com>, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        santosh@chelsio.com, ganeshgr@chelsio.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        QLogic-Storage-Upstream@qlogic.com, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, jth@kernel.org, arvid.brodin@alten.se,
        davem@davemloft.net, leon@kernel.org, sagi@grimberg.me,
        swise@opengridcomputing.com, bart.vanassche@sandisk.com,
        valex@mellanox.com, arnd@arndb.de, weiyj.lk@gmail.com,
        jmaxwell37@gmail.com, varun@chelsio.com, jbenc@redhat.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        devel@linuxdriverproject.org, linux-scsi@vger
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1486182386-50797-1-git-send-email-parav@mellanox.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-02-03 at 22:26 -0600, Parav Pandit wrote:
> This patch makes use of is_vlan_dev() function instead of flag
> comparison which is exactly done by is_vlan_dev() helper function.

Thanks.

btw:  after applying this patch, there is one left

$ git grep -E -n "&\s*IFF_802_1Q_VLAN\b" -- "*.c"
drivers/net/ethernet/chelsio/cxgb4/l2t.c:435:   if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
