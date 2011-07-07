From: MaoXiaoyun <tinnycloud@hotmail.com>
Subject: RE: bnx2: FTQ dump on heavy workload(bnx2-2.0.23b + kernel
 2.6.32.36)
Date: Thu, 7 Jul 2011 19:21:33 +0800
Message-ID: <BLU157-w638818898050394601516DA410@phx.gbl>
References: <S1752689Ab1GDHSa/20110704071830Z+4842@vger.kernel.org>,<BLU157-w63DCDB99F9F311C7BF326EDA5C0@phx.gbl>,<BLU157-w1411DC0D9D19FE3A6935F5DA5C0@phx.gbl>,<blu157-w30B8D4FBD571396FC81A04DA5C0@phx.gbl>,<C27F8246C663564A84BB7AB343977242667C64FA19@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: 8bit
Cc: <davidch@broadcom.com>
To: <mchan@broadcom.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s37.blu0.hotmail.com ([65.55.116.48]:11286 "EHLO
	blu0-omc1-s37.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755721Ab1GGLVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:21:35 -0400
In-Reply-To: <C27F8246C663564A84BB7AB343977242667C64FA19@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi:
 
I've added more register to dump.
Hope this helps. Thanks.
 
 
---[ end trace cdb56f702ac69a53 ]---
bnx2: <--- start FTQ dump on peth0 --->
bnx2: peth0: BNX2_RV2P_PFTQ_CTL 10000
bnx2: peth0: BNX2_RV2P_TFTQ_CTL 20000
bnx2: peth0: BNX2_RV2P_MFTQ_CTL 4000
bnx2: peth0: BNX2_TBDR_FTQ_CTL 1004002
bnx2: peth0: BNX2_TDMA_FTQ_CTL 4010002
bnx2: peth0: BNX2_TXP_FTQ_CTL 4010002
bnx2: peth0: BNX2_TPAT_FTQ_CTL 10002
bnx2: peth0: BNX2_RXP_CFTQ_CTL 8000
bnx2: peth0: BNX2_RXP_FTQ_CTL 100000
bnx2: peth0: BNX2_COM_COMXQ_FTQ_CTL 10000
bnx2: peth0: BNX2_COM_COMTQ_FTQ_CTL 20000
bnx2: peth0: BNX2_COM_COMQ_FTQ_CTL 10000
bnx2: peth0: BNX2_CP_CPQ_FTQ_CTL 4000
bnx2: peth0: TXP mode b84c state 80005000 evt_mask 500 pc 8000758 pc 8000758 instr 8fa90030
bnx2: peth0: TPAT mode b84c state 80001000 evt_mask 500 pc 8000a4c pc 8000a5c instr 10400016
bnx2: peth0: RXP mode b84c state 80001000 evt_mask 500 pc 8004c20 pc 8004c10 instr 32050003
bnx2: peth0: COM mode b8cc state 80000000 evt_mask 500 pc 8000a98 pc 8000a94 instr 8821
bnx2: peth0: CP mode b8cc state 80004000 evt_mask 500 pc 8000ca8 pc 8000920 instr 8f890014
bnx2: <--- end FTQ dump on peth0 --->
 

bnx2: <--- start extra FTQ dump on peth0 --->
bnx2: peth0: BNX2_TBDR_STATUS 42
bnx2: peth0: BNX2_TBDR_CONFIG 4000040
bnx2: peth0: BNX2_TBDR_DEBUG_VECT_PEEK 70007
bnx2: peth0: BNX2_TBDR_CKSUM_ERROR_STATUS 0
bnx2: peth0: BNX2_TBDR_TBDRQ 0
bnx2: peth0: BNX2_TDMA_STATUS 420000
bnx2: peth0: BNX2_TDMA_CONFIG 310088c
bnx2: peth0: BNX2_TDMA_PAYLOAD_PROD 9480
bnx2: peth0: BNX2_TDMA_DMAD_STATUS 0
bnx2: peth0: BNX2_TDMA_DR_INTF_FSM 0
bnx2: peth0: BNX2_TDMA_DR_INTF_STATUS 0
bnx2: peth0: BNX2_TDMA_TDMAQ 0
bnx2: peth0: BNX2_TXP_CPU_MODE b84c
bnx2: peth0: BNX2_TXP_CPU_STATE 80005000
bnx2: peth0: BNX2_TXP_CPU_EVENT_MASK 500
bnx2: peth0: BNX2_TXP_SCRATCH a00002a
bnx2: peth0: BNX2_TXP_CPU_REG_FILE 8007f6c
bnx2: peth0: BNX2_TXP_TXPQ 0
bnx2: peth0: BNX2_TPAT_CPU_MODE b84c
bnx2: peth0: BNX2_TPAT_CPU_STATE 80001000
bnx2: peth0: BNX2_TPAT_CPU_EVENT_MASK 500
bnx2: peth0: BNX2_TPAT_CPU_PROGRAM_COUNTER 8000a54
bnx2: peth0: BNX2_TPAT_TPATQ 0
bnx2: peth0: BNX2_TPAT_SCRATCH0
bnx2: <--- end extra FTQ dump on peth0 --->

bnx2: peth0 DEBUG: intr_sem[0]
bnx2: peth0 DEBUG: intr_sem[0] PCI_CMD[20100406]
bnx2: peth0 DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
bnx2: peth0 DEBUG: EMAC_TX_STATUS[00000008] EMAC_RX_STATUS[00000000]
bnx2: peth0 RPM_MGMT_PKT_CTRL[40000088]
bnx2: peth0 DEBUG: MCP_STATE_P0[0007e10e] MCP_STATE_P1[0003e00e]
bnx2: peth0 DEBUG: HC_STATS_INTERRUPT_STATUS[01ff0000]
bnx2: peth0 DEBUG: PBA[00000000]
BNX2_PCICFG_INT_ACK_CMD[0401f8d4]
bnx2: peth0: prevent chip reset during tx timeout
last status idx 34554 
hw_tx_cons 60308, txr->hw_tx_conds 60308 txr->tx_prod 60429 txr->tx_cons 60301
hw_rx_cons 19366, txr->hw_rx_conds 19366
sblk->status_attn_bits 1
sblk->status_attn_bits_ack 1
bnx2_tx_avail 127 
sblk->status_tx_quick_consumer_index0 60308
sblk->status_tx_quick_consumer_index1 0
sblk->status_tx_quick_consumer_index2 0
sblk->status_tx_quick_consumer_index3 0
sblk->status_rx_quick_consumer_index0 19366
sblk->status_rx_quick_consumer_index1 0
sblk->status_rx_quick_consumer_index2 0
sblk->status_rx_quick_consumer_index3 0
sblk->status_rx_quick_consumer_index4 0
sblk->status_rx_quick_consumer_index5 0
sblk->status_rx_quick_consumer_index6 0
sblk->status_rx_quick_consumer_index7 0
sblk->status_rx_quick_consumer_index8 0
sblk->status_rx_quick_consumer_index9 0
sblk->status_rx_quick_consumer_index10 0
sblk->status_rx_quick_consumer_index11 0
sblk->status_rx_quick_consumer_index12 0
sblk->status_rx_quick_consumer_index13 0
sblk->status_rx_quick_consumer_index14 0
sblk->status_rx_quick_consumer_index15 0
sblk->status_completion_producer_index 0
sblk->status_cmd_consumer_index 0
sblk->status_idx 34554
sblk->status_unused 0
sblk->status_blk_num 0



> From: mchan@broadcom.com
> To: tinnycloud@hotmail.com; netdev@vger.kernel.org
> CC: davidch@broadcom.com
> Date: Mon, 4 Jul 2011 10:04:25 -0700
> Subject: Re: bnx2: FTQ dump on heavy workload(bnx2-2.0.23b + kernel 2.6.32.36)
> 
> MaoXiaoyun wrote:
> 
> > Could it be caused by the similar timeout as
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-
> > 2.6.git;a=commit;h=c441b8d2cb2194b05550a558d6d95d8944e56a84.
> 
> Based on the register dump below, it is not caused by the MSI-X issue.
> 
> > 
> > Maybe timeout still happens in my test scenerino.
> > 
> > Well, from the patch, BNX2_MISC_ECO_HW_CTL is defined 0x000008cc. But I
> > cannot find
> > the defines in programmer reference Guide.(NetXtremeII-PG203-R.pdf).
> > Could some help
> > to point out for me or is the doc is out of date.
> 
> I will request the document to be updated to describe that register. We
> are increasing the register read and write timeout value to workaround
> the problem of the MSI-X table being updated while there is a pending
> MSI-X. Without the patch, the write to unmask the MSI-X table entry can
> be dropped by the chip.
> 
> > 
> > Also, is there a way to comfirm whether the timeout really happen?
> > (which regisiter
> > shall I read?) Or is there a bigger timeout I can set?
> 
> Again, the register dump shows that it is not caused by this issue. I'll
> send you some additional debug patch to try to debug the problem.
> 
> Thanks.
> > 
> > thanks.
> > 
> > ----------------------------------------
> > > From: tinnycloud@hotmail.com
> > > To: netdev@vger.kernel.org
> > > Subject: bnx2: FTQ dump on heavy workload(bnx2-2.0.23b + kernel
> > 2.6.32.36)
> > > Date: Mon, 4 Jul 2011 15:40:01 +0800
> > >
> > >
> > > Hi:
> > >
> > > I met bnx2 FTQ dump over and over again during my testing on Xen live
> > migration which generate
> > > heavy network workload.
> > >
> > > I have two physcial machine, both have xen 4.0.1 installed, and
> > kernel 2.6.32.36, bnx2 2.0.23b.
> > > I start 15 Virtual Machines totoally, and doing migration between the
> > host over and over again,
> > > about 16hours, the network will not work, and sometimes, it can reset
> > successfully, sometimes, it
> > > cause kernel crash.
> > >
> > > I've tried debug some, add code in the driver. below is the code when
> > FTQ happened.
> > > It looks like the NIC is stop transmit the packets, and cause
> > timeout.
> > >
> > > BTW, cpu max_cstate=1 in my grub.
> > >
> > > Thanks.
> > >
> > > --------------
> > > static void
> > > bnx2_tx_timeout(struct net_device *dev)
> > > {
> > > struct bnx2 *bp = netdev_priv(dev);
> > > struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> > > struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
> > > struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
> > > int i ;
> > > bnx2_dump_ftq(bp);
> > > bnx2_dump_state(bp);
> > > if (stop_on_tx_timeout) {
> > > printk(KERN_WARNING PFX
> > > "%s: prevent chip reset during tx timeout\n",
> > > bp->dev->name);
> > > smp_rmb();
> > > printk("last status idx %d \n", bnapi->last_status_idx);
> > > printk("hw_tx_cons %d, txr->hw_tx_conds %d txr->tx_prod %d txr-
> > >tx_cons %d\n",
> > > bnx2_get_hw_tx_cons(bnapi), txr->hw_tx_cons, txr->tx_prod, txr-
> > >tx_cons);
> > > printk("hw_rx_cons %d, txr->hw_rx_conds %d\n",
> > bnx2_get_hw_rx_cons(bnapi), rxr->rx_cons);
> > > printk("sblk->status_attn_bits %d\n",bnapi->status_blk.msi-
> > >status_attn_bits);
> > > printk("sblk->status_attn_bits_ack %d\n",bnapi->status_blk.msi-
> > >status_attn_bits_ack);
> > > printk("bnx2_tx_avail %d \n",(bnx2_tx_avail(bp, txr)));
> > > printk("sblk->status_tx_quick_consumer_index0 %d\n",bnapi-
> > >status_blk.msi->status_tx_quick_consumer_index0);
> > > printk("sblk->status_tx_quick_consumer_index1 %d\n",bnapi-
> > >status_blk.msi->status_tx_quick_consumer_index1);
> > > printk("sblk->status_tx_quick_consumer_index2 %d\n",bnapi-
> > >status_blk.msi->status_tx_quick_consumer_index2);
> > > printk("sblk->status_tx_quick_consumer_index3 %d\n",bnapi-
> > >status_blk.msi->status_tx_quick_consumer_index3);
> > > printk("sblk->status_rx_quick_consumer_index0 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index0);
> > > printk("sblk->status_rx_quick_consumer_index1 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index1);
> > > printk("sblk->status_rx_quick_consumer_index2 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index2);
> > > printk("sblk->status_rx_quick_consumer_index3 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index3);
> > > printk("sblk->status_rx_quick_consumer_index4 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index4);
> > > printk("sblk->status_rx_quick_consumer_index5 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index5);
> > > printk("sblk->status_rx_quick_consumer_index6 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index6);
> > > printk("sblk->status_rx_quick_consumer_index7 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index7);
> > > printk("sblk->status_rx_quick_consumer_index8 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index8);
> > > printk("sblk->status_rx_quick_consumer_index9 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index9);
> > > printk("sblk->status_rx_quick_consumer_index10 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index10);
> > > printk("sblk->status_rx_quick_consumer_index11 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index11);
> > > printk("sblk->status_rx_quick_consumer_index12 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index12);
> > > printk("sblk->status_rx_quick_consumer_index13 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index13);
> > > printk("sblk->status_rx_quick_consumer_index14 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index14);
> > > printk("sblk->status_rx_quick_consumer_index15 %d\n",bnapi-
> > >status_blk.msi->status_rx_quick_consumer_index15);
> > > printk("sblk->status_completion_producer_index %d\n",bnapi-
> > >status_blk.msi->status_completion_producer_index);
> > > printk("sblk->status_cmd_consumer_index %d\n",bnapi->status_blk.msi-
> > >status_cmd_consumer_index);
> > > printk("sblk->status_idx %d\n",bnapi->status_blk.msi->status_idx);
> > > printk("sblk->status_unused %d\n",bnapi->status_blk.msi-
> > >status_unused);
> > > printk("sblk->status_blk_num %d\n",bnapi->status_blk.msi-
> > >status_blk_num);
> > > is_timedout = 1;
> > > for (i = 0; i < bp->irq_nvecs; i++) {
> > > bnapi = &bp->bnx2_napi[i];
> > > bnx2_tx_int(bp, bnapi, 0);
> > > }
> > > return;
> > > }
> > > -----------------
> > >
> > > -------------FTQ log in /var/log/message
> > > ------------[ cut here ]------------
> > > WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x105/0x16a()
> > > Hardware name: Tecal RH2285
> > > Modules linked in: iptable_filter ip_tables nfs fscache nfs_acl
> > auth_rpcgss bridge stp llc autofs4 ipmi_devintf ipmi_si ipmi_msghandler
> > lockd sunrpc ipv6 xenfs dm_multipath fuse xen_netback xen_blkback
> > blktap blkback_pagemap loop nbd video output sbs sbshc parport_pc lp
> > parport snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> > snd_seq_device snd_pcm_oss snd_mixer_oss bnx2 serio_raw snd_pcm
> > snd_timer snd soundcore snd_page_alloc i2c_i801 iTCO_wdt
> > iTCO_vendor_support i2c_core pata_acpi ata_generic pcspkr ata_piix
> > shpchp mptsas mptscsih mptbase [last unloaded: freq_table]
> > > Pid: 0, comm: swapper Not tainted 2.6.32.36xen #1
> > > Call Trace:
> > > <IRQ> [<ffffffff813ba154>] ? dev_watchdog+0x105/0x16a
> > > [<ffffffff81056666>] warn_slowpath_common+0x7c/0x94
> > > [<ffffffff81056738>] warn_slowpath_fmt+0xa4/0xa6
> > > [<ffffffff81080bfa>] ? clockevents_program_event+0x78/0x81
> > > [<ffffffff81081fce>] ? tick_program_event+0x2a/0x2c
> > > [<ffffffff813b951d>] ? __netif_tx_lock+0x1b/0x24
> > > [<ffffffff813b95a8>] ? netif_tx_lock+0x46/0x6e
> > > [<ffffffff813a3ed1>] ? netdev_drivername+0x48/0x4f
> > > [<ffffffff813ba154>] dev_watchdog+0x105/0x16a
> > > [<ffffffff81063d98>] run_timer_softirq+0x156/0x1f8
> > > [<ffffffff813ba04f>] ? dev_watchdog+0x0/0x16a
> > > [<ffffffff8105d6f0>] __do_softirq+0xd7/0x19e
> > > [<ffffffff81013eac>] call_softirq+0x1c/0x30
> > > [<ffffffff8101564b>] do_softirq+0x46/0x87
> > > [<ffffffff8105d575>] irq_exit+0x3b/0x7a
> > > [<ffffffff8128dcfe>] xen_evtchn_do_upcall+0x38/0x46
> > > [<ffffffff81013efe>] xen_do_hypervisor_callback+0x1e/0x30
> > > <EOI> [<ffffffff8103f642>] ? pick_next_task_idle+0x18/0x22
> > > [<ffffffff810093aa>] ? hypercall_page+0x3aa/0x1000
> > > [<ffffffff810093aa>] ? hypercall_page+0x3aa/0x1000
> > > [<ffffffff8100f1bb>] ? xen_safe_halt+0x10/0x1a
> > > [<ffffffff81019e14>] ? default_idle+0x39/0x56
> > > [<ffffffff81011cd0>] ? cpu_idle+0x5d/0x8c
> > > [<ffffffff8143375d>] ? cpu_bringup_and_idle+0x13/0x15
> > > ---[ end trace 867bb8f6cd959b03 ]---
> > > bnx2: <--- start FTQ dump on peth0 --->
> > > bnx2: peth0: BNX2_RV2P_PFTQ_CTL 10000
> > > bnx2: peth0: BNX2_RV2P_TFTQ_CTL 20000
> > > bnx2: peth0: BNX2_RV2P_MFTQ_CTL 4000
> > > bnx2: peth0: BNX2_TBDR_FTQ_CTL 1004002
> > > bnx2: peth0: BNX2_TDMA_FTQ_CTL 4010002
> > > bnx2: peth0: BNX2_TXP_FTQ_CTL 2410002
> > > bnx2: peth0: BNX2_TPAT_FTQ_CTL 10002
> > > bnx2: peth0: BNX2_RXP_CFTQ_CTL 8000
> > > bnx2: peth0: BNX2_RXP_FTQ_CTL 100000
> > > bnx2: peth0: BNX2_COM_COMXQ_FTQ_CTL 10000
> > > bnx2: peth0: BNX2_COM_COMTQ_FTQ_CTL 20000
> > > bnx2: peth0: BNX2_COM_COMQ_FTQ_CTL 10000
> > > bnx2: peth0: BNX2_CP_CPQ_FTQ_CTL 4000
> > > bnx2: peth0: TXP mode b84c state 80005000 evt_mask 500 pc 8000d60 pc
> > 8000d60 instr 8f860000
> > > bnx2: peth0: TPAT mode b84c state 80009000 evt_mask 500 pc 8000a5c pc
> > 8000a5c instr 10400016
> > > bnx2: peth0: RXP mode b84c state 80001000 evt_mask 500 pc 8004c14 pc
> > 8004c14 instr 10e00088
> > > bnx2: peth0: COM mode b8cc state 80000000 evt_mask 500 pc 8000b28 pc
> > 8000a9c instr 8c530000
> > > bnx2: peth0: CP mode b8cc state 80000000 evt_mask 500 pc 8000c50 pc
> > 8000c58 instr 8ca50020
> > > bnx2: <--- end FTQ dump on peth0 --->
> > > bnx2: peth0 DEBUG: intr_sem[0]
> > > bnx2: peth0 DEBUG: intr_sem[0] PCI_CMD[20100406]
> > > bnx2: peth0 DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
> > > bnx2: peth0 DEBUG: EMAC_TX_STATUS[00000008] EMAC_RX_STATUS[00000000]
> > > bnx2: peth0 RPM_MGMT_PKT_CTRL[40000088]
> > > bnx2: peth0 DEBUG: MCP_STATE_P0[0007e10e] MCP_STATE_P1[0003e00e]
> > > bnx2: peth0 DEBUG: HC_STATS_INTERRUPT_STATUS[01ff0000]
> > > bnx2: peth0 DEBUG: PBA[00000000]
> > > BNX2_PCICFG_INT_ACK_CMD[00013ce1]
> > > bnx2: peth0: prevent chip reset during tx timeout
> > > last status idx 2426
> > > hw_tx_cons 32474, txr->hw_tx_conds 32474 txr->tx_prod 32641 txr-
> > >tx_cons 32474
> > > hw_rx_cons 19665, txr->hw_rx_conds 19665
> > > sblk->status_attn_bits 1
> > > sblk->status_attn_bits_ack 1
> > > bnx2_tx_avail 88
> > > sblk->status_tx_quick_consumer_index0 32474
> > > sblk->status_tx_quick_consumer_index1 0
> > > sblk->status_tx_quick_consumer_index2 0
> > > sblk->status_tx_quick_consumer_index3 0
> > > sblk->status_rx_quick_consumer_index0 19665
> > > sblk->status_rx_quick_consumer_index1 0
> > > sblk->status_rx_quick_consumer_index2 0
> > > sblk->status_rx_quick_consumer_index3 0
> > > sblk->status_rx_quick_consumer_index4 0
> > > sblk->status_rx_quick_consumer_index5 0
> > > sblk->status_rx_quick_consumer_index6 0
> > > sblk->status_rx_quick_consumer_index7 0
> > > sblk->status_rx_quick_consumer_index8 0
> > > sblk->status_rx_quick_consumer_index9 0
> > > sblk->status_rx_quick_consumer_index10 0
> > > sblk->status_rx_quick_consumer_index11 0
> > > sblk->status_rx_quick_consumer_index12 0
> > > sblk->status_rx_quick_consumer_index13 0
> > > sblk->status_rx_quick_consumer_index14 0
> > > sblk->status_rx_quick_consumer_index15 0
> > > sblk->status_completion_producer_index 0
> > > sblk->status_cmd_consumer_index 0
> > > sblk->status_idx 2426
> > > sblk->status_unused 0
> > > sblk->status_blk_num 0
> > > hw_cons 32474 sw_cons 32474 ffff8801d27f85c0 bnapi
> > > return hw_cons 32474 sw_cons 32474 ffff8801d27f85c0 bnapi
> > > hw_cons 3628 sw_cons 3625 ffff8801d27f8bc0 bnapi
> > > return hw_cons 3628 sw_cons 3625 ffff8801d27f8bc0 bnapi
> > > hw_cons 62094 sw_cons 62090 ffff8801d27f91c0 bnapi
> > > return hw_cons 62094 sw_cons 62090 ffff8801d27f91c0 bnapi
> > > hw_cons 3184 sw_cons 3173 ffff8801d27f97c0 bnapi
> > > return hw_cons 3184 sw_cons 3173 ffff8801d27f97c0 bnapi
> > > hw_cons 0 sw_cons 0 ffff8801d27f9dc0 bnapi
> > > return hw_cons 0 sw_cons 0 ffff8801d27f9dc0 bnapi
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html 		 	   		  
