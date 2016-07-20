From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v17 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 20 Jul 2016 01:48:18 +0000
Message-ID: <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182D860B8B31579770E3798BF330@CO2PR03MB2182.namprd03.prod.outlook.com>
 <201607200149.0W6994tY%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>,
	"Michal Kubecek" <mkubecek@suse.cz>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"Dave Scott" <dave.scott@docker.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201607200149.0W6994tY%fengguang.wu@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: kbuild test robot [mailto:lkp@intel.com]
> Sent: Wednesday, July 20, 2016 1:10
> 
> Hi,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Dexuan-Cui/introduce-
> Hyper-V-VM-Sockets-hv_sock/20160715-223433
> config: x86_64-randconfig-a0-07191719 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
> 
> All warnings (new ones prefixed by >>):
> 
>    net/hv_sock/af_hvsock.c: In function 'hvsock_open_connection':
>    net/hv_sock/af_hvsock.c:693: warning: 'hvsk' may be used uninitialized in
> this function
>    net/hv_sock/af_hvsock.c:693: warning: 'new_hvsk' may be used
> uninitialized in this function
>    net/hv_sock/af_hvsock.c:697: warning: 'new_sk' may be used uninitialized
> in this function
>    net/hv_sock/af_hvsock.c: In function 'hvsock_sendmsg_wait':
>    net/hv_sock/af_hvsock.c:1053: warning: 'ret' may be used uninitialized in
> this function
> >> net/hv_sock/af_hvsock.o: warning: objtool: hvsock_on_channel_cb()+0x1d:
> function has unreachable instruction

These warnings are all false alarms.

Thanks,
-- Dexuan
