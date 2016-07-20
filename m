From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v17 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 19 Jul 2016 19:52:53 -0700 (PDT)
Message-ID: <20160719.195253.2126109938824378508.davem@davemloft.net>
References: <CO2PR03MB2182D860B8B31579770E3798BF330@CO2PR03MB2182.namprd03.prod.outlook.com>
	<201607200149.0W6994tY%fengguang.wu@intel.com>
	<CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, kbuild-all@01.org, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com, vkuznets@redhat.com, cavery@redhat.com,
	kys@microsoft.com, joe@perches.com, rolf.neugebauer@docker.com,
	mkubecek@suse.cz, haiyangz@microsoft.com, dave.scott@docker.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Wed, 20 Jul 2016 01:48:18 +0000

>> From: kbuild test robot [mailto:lkp@intel.com]
>> Sent: Wednesday, July 20, 2016 1:10
>> 
>> Hi,
>> 
>> [auto build test WARNING on net-next/master]
>> 
>> url:    https://github.com/0day-ci/linux/commits/Dexuan-Cui/introduce-
>> Hyper-V-VM-Sockets-hv_sock/20160715-223433
>> config: x86_64-randconfig-a0-07191719 (attached as .config)
>> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
>> reproduce:
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64
>> 
>> All warnings (new ones prefixed by >>):
>> 
>>    net/hv_sock/af_hvsock.c: In function 'hvsock_open_connection':
>>    net/hv_sock/af_hvsock.c:693: warning: 'hvsk' may be used uninitialized in
>> this function
>>    net/hv_sock/af_hvsock.c:693: warning: 'new_hvsk' may be used
>> uninitialized in this function
>>    net/hv_sock/af_hvsock.c:697: warning: 'new_sk' may be used uninitialized
>> in this function
>>    net/hv_sock/af_hvsock.c: In function 'hvsock_sendmsg_wait':
>>    net/hv_sock/af_hvsock.c:1053: warning: 'ret' may be used uninitialized in
>> this function
>> >> net/hv_sock/af_hvsock.o: warning: objtool: hvsock_on_channel_cb()+0x1d:
>> function has unreachable instruction
> 
> These warnings are all false alarms.

But you still have to quiet them.
