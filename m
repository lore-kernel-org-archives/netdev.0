From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/4] flow_dissector: Get vlan priority in
 addition to vlan id
Date: Fri, 12 Aug 2016 08:26:07 +0200
Message-ID: <20160812062607.GD1841@nanopsycho.orion>
References: <1470835943-9042-3-git-send-email-hadarh@mellanox.com>
 <201608110519.ecG3SB3c%fengguang.wu@intel.com>
 <CAJL1qvHT_SUO+22wfsTCay-gxMnj8j6pV5NNALaStPeH5H_nLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild test robot <lkp@intel.com>,
	Hadar Hen Zion <hadarh@mellanox.com>, kbuild-all@01.org,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirva@gmail.com>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35042 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbcHLG0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 02:26:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so1065665wmg.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 23:26:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJL1qvHT_SUO+22wfsTCay-gxMnj8j6pV5NNALaStPeH5H_nLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 11, 2016 at 05:23:00PM CEST, hadarh@dev.mellanox.co.il wrote:
>On Thu, Aug 11, 2016 at 12:58 AM, kbuild test robot <lkp@intel.com> wrote:
>> Hi Hadar,
>>
>> [auto build test ERROR on net-next/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Hadar-Hen-Zion/flow_dissector-Get-vlan-info-from-skb-vlan_tci-instead-of-skb-data/20160811-042500
>> config: cris-etrax-100lx_v2_defconfig (attached as .config)
>> compiler: cris-linux-gcc (GCC) 4.6.3
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=cris
>>
>> All errors (new ones prefixed by >>):
>>
>>    In function 'flow_keys_hash_length.isra.6',
>>        inlined from '__flow_hash_from_keys' at net/core/flow_dissector.c:599:26,
>>        inlined from 'flow_hash_from_keys' at net/core/flow_dissector.c:610:2:
>>>> net/core/flow_dissector.c:512:2: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
>
>[...]
>
>
>I'm working on a fix, will send it soon.
>
>I'll be happy to get your review and comments on my flow_dissector and
>flower patches.


This patch looks good to me. I'll ack the fixed version. Thanks.
