From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v17 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 20 Jul 2016 04:05:24 +0000
Message-ID: <CO2PR03MB2182719895483CC73897DDF0BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182D860B8B31579770E3798BF330@CO2PR03MB2182.namprd03.prod.outlook.com>
 <201607200149.0W6994tY%fengguang.wu@intel.com>
 <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160719.195253.2126109938824378508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "dave.scott@docker.com" <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
 "kbuild-all@01.org" <kbuild-all@01.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160719.195253.2126109938824378508.davem@davemloft.net>
Content-Language: en-US
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

> From: David Miller [mailto:davem@davemloft.net]
> >> From: kbuild test robot [mailto:lkp@intel.com]
> >> [auto build test WARNING on net-next/master]
> >>
> >> url:    https://github.com/0day-ci/linux/commits/Dexuan-Cui/introduce-
> >> Hyper-V-VM-Sockets-hv_sock/20160715-223433
> >> config: x86_64-randconfig-a0-07191719 (attached as .config)
> >> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> >> reproduce:
> >>         # save the attached .config to linux build tree
> >>         make ARCH=x86_64
> >>
> >> All warnings (new ones prefixed by >>):
> >>
> >>    net/hv_sock/af_hvsock.c: In function 'hvsock_open_connection':
> >>    net/hv_sock/af_hvsock.c:693: warning: 'hvsk' may be used uninitialized
> in
> >> this function
> >>    net/hv_sock/af_hvsock.c:693: warning: 'new_hvsk' may be used
> >> uninitialized in this function
> >>    net/hv_sock/af_hvsock.c:697: warning: 'new_sk' may be used
> uninitialized
> >> in this function
> >>    net/hv_sock/af_hvsock.c: In function 'hvsock_sendmsg_wait':
> >>    net/hv_sock/af_hvsock.c:1053: warning: 'ret' may be used uninitialized
> in
> >> this function
> >> >> net/hv_sock/af_hvsock.o: warning: objtool:
> hvsock_on_channel_cb()+0x1d:
> >> function has unreachable instruction
> >
> > These warnings are all false alarms.
> 
> But you still have to quiet them.

Sure. Will do.

Thanks,
-- Dexuan
