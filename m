From: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] New flags for Fibre Channel over Ethernet
	(FCoE)
Date: Mon, 06 Oct 2008 15:09:15 -0700
Message-ID: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
I am working on the Fibre Channel over Ethernet (FCoE) at open-fcoe.org and
would like to add the following new define/feature flogs in netdev for FCoE.

The first patch adds the protocol type as ETH_P_FCOE for FCoE protocol and the
second one adds offload feature flags for FCoE in netdev, which is based on
the earlier post: http://marc.info/?l=linux-netdev&m=122228979113312&w=2.

Thanks.

yi
---

Chris Leech (1):
      net: define feature flags for FCoE offloads

Yi Zou (1):
      net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)


 include/linux/if_ether.h  |    1 +
 include/linux/netdevice.h |    3 +++
 include/linux/skbuff.h    |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

-- 
Signature : Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
