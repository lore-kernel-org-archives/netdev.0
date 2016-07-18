From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v2 04/10] net/ncsi: Package and channel
 management
Date: Mon, 18 Jul 2016 10:16:38 +1000
Message-ID: <20160718001638.GB18521@gwshan>
References: <1468579460-13768-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <201607152200.fUmBZc56%fengguang.wu@intel.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, kbuild-all@01.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, joel@jms.id.au, gerlitz.or@gmail.com,
	weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:11675 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751343AbcGRAQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 20:16:47 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6I0EItC096384
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 20:16:46 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2482fvk457-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 20:16:46 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 18 Jul 2016 10:16:43 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2563C2CE8054
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 10:16:41 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6I0GfDZ27000980
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 10:16:41 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6I0Gd3D001213
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 10:16:40 +1000
Content-Disposition: inline
In-Reply-To: <201607152200.fUmBZc56%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 10:30:00PM +0800, kbuild test robot wrote:
>[auto build test ERROR on net-next/master]
>
>url:    https://github.com/0day-ci/linux/commits/Gavin-Shan/NCSI-Support/20160715-190549
>config: i386-allmodconfig (attached as .config)
>compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
>reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=i386 
>
>All error/warnings (new ones prefixed by >>):
>
>   In file included from include/linux/swab.h:4:0,
>                    from include/uapi/linux/byteorder/little_endian.h:12,
>                    from include/linux/byteorder/little_endian.h:4,
>                    from arch/x86/include/uapi/asm/byteorder.h:4,
>                    from include/asm-generic/bitops/le.h:5,
>                    from arch/x86/include/asm/bitops.h:504,
>                    from include/linux/bitops.h:36,
>                    from include/linux/kernel.h:10,
>                    from include/linux/list.h:8,
>                    from include/linux/module.h:9,
>                    from net/ncsi/ncsi-manage.c:10:
>   net/ncsi/ncsi-manage.c: In function 'ncsi_register_dev':
>>> net/ncsi/ncsi-manage.c:1134:32: error: 'ETH_P_NCSI' undeclared (first use in this function)
>     ndp->ptype.type = cpu_to_be16(ETH_P_NCSI);
>                                   ^

Same to breakage caused by PATCH[02/10]. The ETH_P_NCSI definition in
include/uapi/linux/if_ether.h was missed from this series. I will fix
it in next respin to address comments received for this series.

Thanks,
Gavin
