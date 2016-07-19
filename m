From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v2 02/10] net/ncsi: NCSI command packet handler
Date: Tue, 19 Jul 2016 11:48:18 +1000
Message-ID: <20160719014818.GA8923@gwshan>
References: <1468579460-13768-3-git-send-email-gwshan@linux.vnet.ibm.com>
 <201607152216.y8YtsYou%fengguang.wu@intel.com>
 <20160718001521.GA18521@gwshan>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, joel@jms.id.au, gerlitz.or@gmail.com,
	weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:31086 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752097AbcGSBs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:48:26 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1i4o8000908
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:48:25 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2495r7fun1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:48:24 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:48:22 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id AE8612CE8054
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:48:20 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1mKEG20447464
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:48:20 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1mJXD010323
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:48:20 +1000
Content-Disposition: inline
In-Reply-To: <20160718001521.GA18521@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 10:15:21AM +1000, Gavin Shan wrote:
>On Fri, Jul 15, 2016 at 10:08:23PM +0800, kbuild test robot wrote:
>>[auto build test ERROR on net-next/master]
>>
>>url:    https://github.com/0day-ci/linux/commits/Gavin-Shan/NCSI-Support/20160715-190549
>>config: i386-allmodconfig (attached as .config)
>>compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
>>reproduce:
>>        # save the attached .config to linux build tree
>>        make ARCH=i386 
>>
>>All error/warnings (new ones prefixed by >>):
>>
>>   In file included from include/linux/swab.h:4:0,
>>                    from include/uapi/linux/byteorder/little_endian.h:12,
>>                    from include/linux/byteorder/little_endian.h:4,
>>                    from arch/x86/include/uapi/asm/byteorder.h:4,
>>                    from include/asm-generic/bitops/le.h:5,
>>                    from arch/x86/include/asm/bitops.h:504,
>>                    from include/linux/bitops.h:36,
>>                    from include/linux/kernel.h:10,
>>                    from include/linux/list.h:8,
>>                    from include/linux/module.h:9,
>>                    from net/ncsi/ncsi-cmd.c:10:
>>   net/ncsi/ncsi-cmd.c: In function 'ncsi_alloc_command':
>>>> net/ncsi/ncsi-cmd.c:301:24: error: 'ETH_P_NCSI' undeclared (first use in this function)
>>     skb->protocol = htons(ETH_P_NCSI);
>>                           ^
>
>The ETH_P_NCSI definition in include/uapi/linux/if_ether.h was missed from this series. I
>will fix it in next respin to address comments received from this series.
>

I will send followup v3 shortly since David marked this series as "change requested"
in patchwork.

Thanks,
Gavin
