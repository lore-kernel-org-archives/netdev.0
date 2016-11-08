From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Tue, 8 Nov 2016 12:04:48 -0800
Message-ID: <alpine.LRH.2.00.1611081129440.28058@mvluser05.qlc.com>
References: <201611081805.KzpHTNxg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Manish Rangankar <manish.rangankar@cavium.com>,
        <kbuild-all@01.org>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        James Bottomley <jejb@linux.vnet.ibm.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0086.outbound.protection.outlook.com ([104.47.38.86]:64384
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752087AbcKHXkb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 18:40:31 -0500
In-Reply-To: <201611081805.KzpHTNxg%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Sending on behalf of Manish to cover for the time difference. ]

Hi Martin, James,

I would like to request your input on this kbuild test error on the 
series, where they compile fine together, but is not bisectable.

qedi is the new iSCSI driver, which we are trying to submit, for our 41000 
series CNA. This patch series were broken up into logical blocks for 
review purpose, but were not made to compile individually. It is our 
impression that this is acceptable for SCSI and all the initial "qedi" 
patches will be squashed and committed as a single commit. Please let us 
know if we are mistaken, and if so, we will post another series 
with this taken care of.

FYI, this series accompany additions to the common core module, "qed", 
that goes under drivers/net/. The patches for the qed module compiles fine 
individually and so is bisectable.

In regards to the additional warnings brought out by kbuild test on 
"PATCH v2 6/6" and "PATCH v2 3/6", we will post a v3 with the fixes.

Regards,
-Arun

On Tue, 8 Nov 2016, 2:52am -0000, kbuild test robot wrote:

> Hi Manish,
> 
> [auto build test ERROR on net-next/master]
> [also build test ERROR on v4.9-rc4]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Manish-Rangankar/qed-Add-support-for-hardware-offloaded-iSCSI/20161108-180027
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 
> Note: the linux-review/Manish-Rangankar/qed-Add-support-for-hardware-offloaded-iSCSI/20161108-180027 HEAD dd4d1d0e0785d20cdcfdf9b2c792c564a79b2de2 builds fine.
>       It only hurts bisectibility.
> 
