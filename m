From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFC v3 net-next 01/10] qed: Add module with basic common support
Date: Wed, 30 Sep 2015 21:50:04 +0800
Message-ID: <201509302134.YaAXjY2f%fengguang.wu@intel.com>
References: <1443618217-18069-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1616 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbbI3NvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 09:51:03 -0400
Content-Disposition: inline
In-Reply-To: <1443618217-18069-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuval,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qed/qed_dev.c:342:16: sparse: incorrect type in argument 4 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_dev.c:342:16:    expected unsigned int [unsigned] [usertype] val
   drivers/net/ethernet/qlogic/qed/qed_dev.c:342:16:    got restricted __le32 [usertype] <noident>
--
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:56:44: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:56:44:    expected restricted __le32 [usertype] offset
   drivers/net/ethernet/qlogic/qed/qed_hw.c:56:44:    got int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:76:35: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:76:35:    expected restricted __le32 [usertype] offset
   drivers/net/ethernet/qlogic/qed/qed_hw.c:76:35:    got int
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:127:26: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:159:27: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:159:27:    expected restricted __le32 [usertype] offset
   drivers/net/ethernet/qlogic/qed/qed_hw.c:159:27:    got unsigned int
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:161:9: sparse: cast from restricted __le32
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:283:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:284:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:290:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:291:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:292:9:    right side has type unsigned long long
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:297:49: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:297:49:    expected restricted __le16 [usertype] fid
   drivers/net/ethernet/qlogic/qed/qed_hw.c:297:49:    got unsigned short [unsigned] [assigned] [usertype] fid
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:310:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:311:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:312:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:324:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:325:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:326:9:    right side has type unsigned long long
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:340:41: sparse: incorrect type in initializer (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:340:41:    expected unsigned int [usertype] *opcode
   drivers/net/ethernet/qlogic/qed/qed_hw.c:340:41:    got restricted __le32 *<noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:341:42: sparse: incorrect type in initializer (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:341:42:    expected unsigned short [usertype] *opcodeB
   drivers/net/ethernet/qlogic/qed/qed_hw.c:341:42:    got restricted __le16 *<noident>
   drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le32
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le16
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le32
   drivers/net/ethernet/qlogic/qed/qed_hw.c:425:9: sparse: cast from restricted __le32
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:585:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:585:34:    expected restricted __le32 [usertype] src_addr_hi
   drivers/net/ethernet/qlogic/qed/qed_hw.c:585:34:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:586:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:586:34:    expected restricted __le32 [usertype] src_addr_lo
   drivers/net/ethernet/qlogic/qed/qed_hw.c:586:34:    got unsigned int [unsigned] [usertype] <noident>
   drivers/net/ethernet/qlogic/qed/qed_hw.c:590:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:590:34:    expected restricted __le32 [usertype] src_addr_hi
   drivers/net/ethernet/qlogic/qed/qed_hw.c:590:34:    got unsigned int [unsigned] [usertype] <noident>
   drivers/net/ethernet/qlogic/qed/qed_hw.c:591:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:591:34:    expected restricted __le32 [usertype] src_addr_lo
   drivers/net/ethernet/qlogic/qed/qed_hw.c:591:34:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:603:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:603:34:    expected restricted __le32 [usertype] dst_addr_hi
   drivers/net/ethernet/qlogic/qed/qed_hw.c:603:34:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:604:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:604:34:    expected restricted __le32 [usertype] dst_addr_lo
   drivers/net/ethernet/qlogic/qed/qed_hw.c:604:34:    got unsigned int [unsigned] [usertype] <noident>
   drivers/net/ethernet/qlogic/qed/qed_hw.c:608:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:608:34:    expected restricted __le32 [usertype] dst_addr_hi
   drivers/net/ethernet/qlogic/qed/qed_hw.c:608:34:    got unsigned int [unsigned] [usertype] <noident>
   drivers/net/ethernet/qlogic/qed/qed_hw.c:609:34: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:609:34:    expected restricted __le32 [usertype] dst_addr_lo
   drivers/net/ethernet/qlogic/qed/qed_hw.c:609:34:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:615:21: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:615:21:    expected restricted __le16 [usertype] length
   drivers/net/ethernet/qlogic/qed/qed_hw.c:615:21:    got unsigned short [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:658:27: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:658:27:    expected restricted __le32 [usertype] comp_addr_lo
   drivers/net/ethernet/qlogic/qed/qed_hw.c:658:27:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:659:27: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:659:27:    expected restricted __le32 [usertype] comp_addr_hi
   drivers/net/ethernet/qlogic/qed/qed_hw.c:659:27:    got unsigned int [unsigned] [usertype] <noident>
>> drivers/net/ethernet/qlogic/qed/qed_hw.c:660:23: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_hw.c:660:23:    expected restricted __le32 [usertype] comp_val
   drivers/net/ethernet/qlogic/qed/qed_hw.c:660:23:    got int
--
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:194:35: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:199:26: sparse: incorrect type in initializer (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:199:26:    expected unsigned int [unsigned] [usertype] dmae_array_offset
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:199:26:    got restricted __le32 [usertype] array_offset
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:208:17: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:211:35: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:231:35: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:235:24: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:249:24: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:268:17: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:269:31: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:280:17: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:282:54: sparse: incorrect type in argument 4 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:282:54:    expected unsigned int [unsigned] [usertype] val
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:282:54:    got restricted __le32 [usertype] inline_val
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:286:46: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:288:61: sparse: incorrect type in argument 5 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:288:61:    expected unsigned int [unsigned] [usertype] fill_count
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:288:61:    got restricted __le32 [usertype] zeros_count
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:291:48: sparse: incorrect type in argument 5 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:291:48:    expected unsigned int [unsigned] [usertype] fill_count
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:291:48:    got restricted __le32 [usertype] zeros_count
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:299:46: sparse: incorrect type in argument 4 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:299:46:    expected unsigned int [unsigned] [usertype] rt_offset
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:299:46:    got restricted __le16 [usertype] offset
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:300:46: sparse: incorrect type in argument 5 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:300:46:    expected unsigned int [unsigned] [usertype] size
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:300:46:    got restricted __le16 [usertype] size
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:330:24: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:338:13: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:341:25: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:361:42: sparse: incorrect type in argument 2 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:361:42:    expected unsigned int [unsigned] [usertype] expected_val
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:361:42:    got restricted __le32 [usertype] expected_val
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:417:27: sparse: incorrect type in initializer (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:417:27:    expected unsigned short [unsigned] [usertype] offset
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:417:27:    got restricted __le16 [usertype] modes_buf_offset
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:422:24: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:430:25: sparse: incorrect type in initializer (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:430:25:    expected unsigned int [unsigned] [usertype] data
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:430:25:    got restricted __le32 [usertype] phase_data
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:435:24: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:464:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:481:34: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:488:25: sparse: restricted __le32 degrades to integer
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:488:25: sparse: restricted __le32 degrades to integer
>> drivers/net/ethernet/qlogic/qed/qed_init_ops.c:488:25: sparse: incorrect type in argument 1 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:488:25:    expected unsigned long [unsigned] usecs
   drivers/net/ethernet/qlogic/qed/qed_init_ops.c:488:25:    got restricted __le32 [usertype] delay
--
>> include/linux/qed/qed_if.h:430:16: sparse: restricted __le32 degrades to integer
>> include/linux/qed/qed_if.h:430:16: sparse: cast to restricted __le32
--
>> drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21:    expected restricted __be32 [usertype] tmp
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21:    got unsigned int

vim +342 drivers/net/ethernet/qlogic/qed/qed_dev.c

   326		command |= id << FINAL_CLEANUP_VFPF_ID_SHIFT;
   327		command |= FINAL_CLEANUP_COMP << SDM_OP_GEN_COMP_TYPE_SHIFT;
   328	
   329		/* Make sure notification is not set before initiating final cleanup */
   330		if (REG_RD(p_hwfn, addr)) {
   331			DP_NOTICE(
   332				p_hwfn,
   333				"Unexpected; Found final cleanup notification before initiating final cleanup\n");
   334			REG_WR(p_hwfn, addr, 0);
   335		}
   336	
   337		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
   338			   "Sending final cleanup for PFVF[%d] [Command %08x\n]",
   339			   id, cpu_to_le32(command));
   340	
   341		qed_wr(p_hwfn, p_ptt, XSDM_REG_OPERATION_GEN,
 > 342		       cpu_to_le32(command));
   343	
   344		/* Poll until completion */
   345		while (!REG_RD(p_hwfn, addr) && count--)
   346			msleep(FINAL_CLEANUP_POLL_TIME);
   347	
   348		if (REG_RD(p_hwfn, addr))
   349			rc = 0;
   350		else

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
