From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops / Warning report for the week of January 28th, 2009: The 200.000th
 trace.
Date: Wed, 28 Jan 2009 10:15:52 -0800
Message-ID: <4980A0D8.80209@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Dave Airlie <airlied@redhat.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:11582 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751212AbZA1SQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 13:16:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kerneloops.org website collected its 200.000th trace yesterday,
and lucky winner is a bug in the cdc_wdm driver (wdm_probe):

http://www.kerneloops.org/raw.php?rawid=200000


Also new this week, the kerneloops.org added the feature where mixed source/asm dumps
get created for module crashes in certain distro kernels (previously only crashes in
the vmlinux created these. In addition, these dumps are now appended to the bottom of
this report (please give feedback about the usefulness of this)


This week, a total of 9375 oopses and warnings have been reported,
compared to 8180 reports in the previous week.


Per file statistics
1384	drivers/net/wireless/iwlwifi/iwl-3945-rs.c
746	external/virtualbox/module
709	arch/x86/include/asm/mtrr.h
551	arch/x86/kernel/hpet.c
305	drivers/gpu/drm/i915/i915_gem.c
294	drivers/net/r8169.c
245	drivers/net/wireless/iwlwifi/iwl-sta.c
232	drivers/net/wireless/iwlwifi/iwl-tx.c
226	drivers/gpu/drm/radeon/radeon_cp.c
200	drivers/net/sis900.c
186	fs/jbd/journal.c
181	net/rfkill/rfkill.c


Rank 1: rs_get_rate (warning)
	Reported 1385 times (8114 total reports)
	Bug in the Intel IWL wireless drivers
	This warning was last seen in version 2.6.29-rc0-git9, and first seen in 2.6.25-rc2-git5.
	More info: http://www.kerneloops.org/searchweek.php?search=rs_get_rate

Rank 2: VBoxDrvLinuxIOCtl (warning)
	Reported 740 times (7017 total reports)
	[external] bug in the VirtualBox drivers
	This warning was last seen in version 2.6.29-rc2-git3, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=VBoxDrvLinuxIOCtl

Rank 3: mtrr_trim_uncached_memory (warning)
	Reported 709 times (14696 total reports)
	BIOS bug (often in VMWare) where the MTRR's are set up incorrectly or not at all
	This warning was last seen in version 2.6.29-rc2-git1, and first seen in 2.6.24.
	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Rank 4: hpet_cpuhp_notify (warning)
	Reported 501 times (1020 total reports)
	Patch available, not yet merged by Linus
	This warning was last seen in version 2.6.29-rc2-git1, and first seen in 2.6.28-rc5.
	More info: http://www.kerneloops.org/searchweek.php?search=hpet_cpuhp_notify

Rank 5: dev_watchdog(r8169) (oops)
	Reported 294 times (3994 total reports)
	This oops was last seen in version 2.6.29-rc1-git4, and first seen in 2.6.26.6.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(r8169)

Rank 6: iwl_set_dynamic_key (warning)
	Reported 245 times (802 total reports)
	This warning was last seen in version 2.6.29-rc2-git1, and first seen in 2.6.27.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_set_dynamic_key

Rank 7: i915_gem_leavevt_ioctl (warning)
	Reported 238 times (1271 total reports)
	This warning was last seen in version 2.6.29-rc2-git1, and first seen in 2.6.27.7.
	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_leavevt_ioctl

Rank 8: iwl_tx_cmd_complete (warning)
	Reported 230 times (5307 total reports)
	This warning was last seen in version 2.6.29-rc2, and first seen in 2.6.27-rc9.
	More info: http://www.kerneloops.org/searchweek.php?search=iwl_tx_cmd_complete

Rank 9: radeon_cp_init_ring_buffer (oops)
	Reported 204 times (1885 total reports)
	drm.git bug in the radeon driver
	This oops was last seen in version 2.6.28-rc8-git2, and first seen in 2.6.25-rc8-git7.
	More info: http://www.kerneloops.org/searchweek.php?search=radeon_cp_init_ring_buffer

Rank 10: dev_watchdog(sis900) (warning)
	Reported 200 times (3304 total reports)
	This warning was last seen in version 2.6.28, and first seen in 2.6.26-rc4-git2.
	More info: http://www.kerneloops.org/searchweek.php?search=dev_watchdog(sis900)

Rank 11: journal_update_superblock (warning)
	Reported 185 times (9335 total reports)
	Likely caused by the user removing a USB stick while mounted
	This warning was last seen in version 2.6.29-rc0-git9, and first seen in 2.6.24-rc6-git1.
	More info: http://www.kerneloops.org/searchweek.php?search=journal_update_superblock

Rank 12: rfkill_force_state (oops)
	Reported 181 times (1535 total reports)
	[fixed] bug in the toshiba ACPI driver; fixed by 23d0a65cf229acd273b6f5a325c34d758a90d592
	This oops was last seen in version 2.6.28-rc8-git2, and first seen in 2.6.27.4.
	More info: http://www.kerneloops.org/searchweek.php?search=rfkill_force_state

Rank 13: tcp_recvmsg (warning)
	Reported 154 times (1548 total reports)
	This warning was last seen in version 2.6.28-rc9-git1, and first seen in 2.6.25.
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_recvmsg




Source disassembly for issue 1:
  		  struct ieee80211_supported_band *sband,
  		  struct sta_info *sta)
  {
  	int i;

  	for (i = 0; i < sband->n_bitrates; i++)
  f88e27e3:	39 d9                	cmp    %ebx,%ecx
  f88e27e5:	7c db                	jl     f88e27c2 <rs_get_rate+0xe6>
  		if (rate_supported(sta, sband->band, i))
  			return i;

  	/* warn when we cannot find a rate. */
  	WARN_ON(1);
  f88e27e7:	b8 11 5f 00 00       	mov    $0x5f11,%eax
  f88e27ec:	ba 98 00 00 00       	mov    $0x98,%edx
*f88e27f1:	e8 fc ff ff ff       	call   f88e27f2 <rs_get_rate+0x116> <--- causing instruction
  f88e27f6:	31 c0                	xor    %eax,%eax
  		sel->rate_idx = rate_lowest_index(local, sband, sta);
  f88e27f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  f88e27fb:	88 02                	mov    %al,(%edx)
  		rcu_read_unlock();
  		return;
  f88e27fd:	e9 c2 05 00 00       	jmp    f88e2dc4 <rs_get_rate+0x6e8>
  	}

  	rate_mask = sta->supp_rates[sband->band];
  f88e2802:	8b 4d a0             	mov    -0x60(%ebp),%ecx
  f88e2805:	8b 7d c8             	mov    -0x38(%ebp),%edi
  	index = min(sta->last_txrate_idx & 0xffff, IWL_RATE_COUNT - 1);
  f88e2808:	8b 45 c8             	mov    -0x38(%ebp),%eax
  		sel->rate_idx = rate_lowest_index(local, sband, sta);
  		rcu_read_unlock();
  		return;




Source disassembly for issue 3:
  	if (range[i].end + 1 < end_pfn)
  		total_trim_size += real_trim_memory(range[i].end + 1,
  c082005c:	01 c6                	add    %eax,%esi
  c082005e:	11 d7                	adc    %edx,%edi
  c0820060:	83 c4 10             	add    $0x10,%esp
  							 end_pfn);

  	if (total_trim_size) {
  c0820063:	89 f8                	mov    %edi,%eax
  c0820065:	09 f0                	or     %esi,%eax
  c0820067:	74 45                	je     c08200ae <mtrr_trim_uncached_memory+0x29f>
  		printk(KERN_WARNING "WARNING: BIOS bug: CPU MTRRs don't cover"
  c0820069:	0f ac fe 14          	shrd   $0x14,%edi,%esi
  c082006d:	c1 ef 14             	shr    $0x14,%edi
  c0820070:	57                   	push   %edi
  c0820071:	56                   	push   %esi
  c0820072:	68 a6 e8 75 c0       	push   $0xc075e8a6
  c0820077:	e8 fe 70 e8 ff       	call   c06a717a <printk>
  			" all of memory, losing %lluMB of RAM.\n",
  			total_trim_size >> 20);

  		if (!changed_by_mtrr_cleanup)
  c082007c:	83 c4 0c             	add    $0xc,%esp
  c082007f:	83 3d 58 8b 84 c0 00 	cmpl   $0x0,0xc0848b58
  c0820086:	75 0f                	jne    c0820097 <mtrr_trim_uncached_memory+0x288>
  			WARN_ON(1);
  c0820088:	ba 13 06 00 00       	mov    $0x613,%edx
  c082008d:	b8 f8 e8 75 c0       	mov    $0xc075e8f8,%eax
*c0820092:	e8 8e cb c0 ff       	call   c042cc25 <warn_on_slowpath> <--- causing instruction

  		printk(KERN_INFO "update e820 for mtrr\n");
  c0820097:	68 18 e9 75 c0       	push   $0xc075e918
  c082009c:	e8 d9 70 e8 ff       	call   c06a717a <printk>
  		update_e820();
  c08200a1:	e8 db d1 ff ff       	call   c081d281 <update_e820>
  c08200a6:	b8 01 00 00 00       	mov    $0x1,%eax

  		return 1;
  c08200ab:	5f                   	pop    %edi
  c08200ac:	eb 02                	jmp    c08200b0 <mtrr_trim_uncached_memory+0x2a1>
  c08200ae:	31 c0                	xor    %eax,%eax
  	}

  	return 0;
  }
  c08200b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  c08200b3:	5b                   	pop    %ebx
  c08200b4:	5e                   	pop    %esi
  c08200b5:	5f                   	pop    %edi
  c08200b6:	5d                   	pop    %ebp
  c08200b7:	c3                   	ret





Source disassembly for issue 5:
  			for (i = 0; i < dev->num_tx_queues; i++) {
  c063fdb8:	46                   	inc    %esi
  c063fdb9:	3b 75 b0             	cmp    -0x50(%ebp),%esi
  c063fdbc:	72 e9                	jb     c063fda7 <dev_watchdog+0x7d>
  c063fdbe:	eb 59                	jmp    c063fe19 <dev_watchdog+0xef>
  					some_queue_stopped = 1;
  					break;
  				}
  			}

  			if (some_queue_stopped &&
  c063fdc0:	8b 15 00 3b 80 c0    	mov    0xc0803b00,%edx
  c063fdc6:	8b 83 20 02 00 00    	mov    0x220(%ebx),%eax
  c063fdcc:	03 83 1c 02 00 00    	add    0x21c(%ebx),%eax
  c063fdd2:	39 d0                	cmp    %edx,%eax
  c063fdd4:	79 43                	jns    c063fe19 <dev_watchdog+0xef>
  			    time_after(jiffies, (dev->trans_start +
  						 dev->watchdog_timeo))) {
  				char drivername[64];
  				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
  c063fdd6:	83 3d 5c 03 97 c0 00 	cmpl   $0x0,0xc097035c
  c063fddd:	75 32                	jne    c063fe11 <dev_watchdog+0xe7>
  c063fddf:	8d 55 b4             	lea    -0x4c(%ebp),%edx
  c063fde2:	b9 40 00 00 00       	mov    $0x40,%ecx
  c063fde7:	89 d8                	mov    %ebx,%eax
  c063fde9:	e8 7a 04 ff ff       	call   c0630268 <netdev_drivername>
  c063fdee:	50                   	push   %eax
  c063fdef:	53                   	push   %ebx
  c063fdf0:	68 f2 b3 7a c0       	push   $0xc07ab3f2
  c063fdf5:	68 db 00 00 00       	push   $0xdb
  c063fdfa:	68 23 b4 7a c0       	push   $0xc07ab423
*c063fdff:	e8 ab cb de ff       	call   c042c9af <warn_slowpath> <--- causing instruction
  c063fe04:	c7 05 5c 03 97 c0 01 	movl   $0x1,0xc097035c
  c063fe0b:	00 00 00
  c063fe0e:	83 c4 14             	add    $0x14,%esp
  				       dev->name, netdev_drivername(dev, drivername, 64));
  				dev->tx_timeout(dev);
  c063fe11:	89 d8                	mov    %ebx,%eax
  c063fe13:	ff 93 cc 02 00 00    	call   *0x2cc(%ebx)
  			}
  			if (!mod_timer(&dev->watchdog_timer,
  c063fe19:	a1 00 3b 80 c0       	mov    0xc0803b00,%eax
  c063fe1e:	03 83 20 02 00 00    	add    0x220(%ebx),%eax
  c063fe24:	e8 05 4f df ff       	call   c0434d2e <round_jiffies>
  c063fe29:	89 c2                	mov    %eax,%edx
  c063fe2b:	8d 83 24 02 00 00    	lea    0x224(%ebx),%eax
  c063fe31:	e8 b4 59 df ff       	call   c04357ea <mod_timer>
  c063fe36:	85 c0                	test   %eax,%eax
  c063fe38:	75 07                	jne    c063fe41 <dev_watchdog+0x117>
   *
   * Atomically increments @v by 1.
   */
  static inline void atomic_inc(atomic_t *v)
  {
  	asm volatile(LOCK_PREFIX "incl %0"
  c063fe3a:	f0 ff 83 80 02 00 00 	lock incl 0x280(%ebx)




Source disassembly for issue 7:
  	}
  f8dfdb96:	eb 9a                	jmp    f8dfdb32 <i915_gem_idle+0xad>
  	dev_priv->mm.waiting_gem_seqno = 0;
  f8dfdb98:	c7 83 78 0e 00 00 00 	movl   $0x0,0xe78(%ebx)
  f8dfdb9f:	00 00 00

  	i915_gem_retire_requests(dev);
  f8dfdba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  f8dfdba5:	e8 fc ff ff ff       	call   f8dfdba6 <i915_gem_idle+0x121>

  	if (!dev_priv->mm.wedged) {
  f8dfdbaa:	83 bb 84 0e 00 00 00 	cmpl   $0x0,0xe84(%ebx)
  f8dfdbb1:	75 57                	jne    f8dfdc0a <i915_gem_idle+0x185>
  		/* Active and flushing should now be empty as we've
  		 * waited for a sequence higher than any pending execbuffer
  		 */
  		WARN_ON(!list_empty(&dev_priv->mm.active_list));
  f8dfdbb3:	8d 83 14 0e 00 00    	lea    0xe14(%ebx),%eax
  f8dfdbb9:	39 83 14 0e 00 00    	cmp    %eax,0xe14(%ebx)
  f8dfdbbf:	74 0f                	je     f8dfdbd0 <i915_gem_idle+0x14b>
  f8dfdbc1:	ba 0a 09 00 00       	mov    $0x90a,%edx
  f8dfdbc6:	b8 7e 07 00 00       	mov    $0x77e,%eax
  f8dfdbcb:	e8 fc ff ff ff       	call   f8dfdbcc <i915_gem_idle+0x147>
  		WARN_ON(!list_empty(&dev_priv->mm.flushing_list));
  f8dfdbd0:	8d 83 1c 0e 00 00    	lea    0xe1c(%ebx),%eax
  f8dfdbd6:	39 83 1c 0e 00 00    	cmp    %eax,0xe1c(%ebx)
  f8dfdbdc:	74 0f                	je     f8dfdbed <i915_gem_idle+0x168>
  f8dfdbde:	ba 0b 09 00 00       	mov    $0x90b,%edx
  f8dfdbe3:	b8 7e 07 00 00       	mov    $0x77e,%eax
*f8dfdbe8:	e8 fc ff ff ff       	call   f8dfdbe9 <i915_gem_idle+0x164> <--- causing instruction
  		/* Request should now be empty as we've also waited
  		 * for the last request in the list
  		 */
  		WARN_ON(!list_empty(&dev_priv->mm.request_list));
  f8dfdbed:	8d 83 2c 0e 00 00    	lea    0xe2c(%ebx),%eax
  f8dfdbf3:	39 83 2c 0e 00 00    	cmp    %eax,0xe2c(%ebx)
  f8dfdbf9:	74 0f                	je     f8dfdc0a <i915_gem_idle+0x185>
  f8dfdbfb:	ba 0f 09 00 00       	mov    $0x90f,%edx
  f8dfdc00:	b8 7e 07 00 00       	mov    $0x77e,%eax
  f8dfdc05:	e8 fc ff ff ff       	call   f8dfdc06 <i915_gem_idle+0x181>
  	/* Empty the active and flushing lists to inactive.  If there's
  	 * anything left at this point, it means that we're wedged and
  	 * nothing good's going to happen by leaving them there.  So strip
  	 * the GPU domains and just stuff them onto inactive.
  	 */
  	while (!list_empty(&dev_priv->mm.active_list)) {
  f8dfdc0a:	8d b3 14 0e 00 00    	lea    0xe14(%ebx),%esi
  f8dfdc10:	eb 0f                	jmp    f8dfdc21 <i915_gem_idle+0x19c>




Source disassembly for issue 8:
  f8a2911c:	57                   	push   %edi
  f8a2911d:	89 d7                	mov    %edx,%edi
  f8a2911f:	56                   	push   %esi
  f8a29120:	53                   	push   %ebx
  f8a29121:	89 c3                	mov    %eax,%ebx
  f8a29123:	83 ec 28             	sub    $0x28,%esp
  	struct iwl_rx_packet *pkt = (struct iwl_rx_packet *)rxb->skb->data;
  f8a29126:	8b 4a 04             	mov    0x4(%edx),%ecx
  f8a29129:	8b b1 ac 00 00 00    	mov    0xac(%ecx),%esi
  	u16 sequence = le16_to_cpu(pkt->hdr.sequence);
  f8a2912f:	66 8b 46 06          	mov    0x6(%esi),%ax
  	int txq_id = SEQ_TO_QUEUE(sequence);
  f8a29133:	0f b6 d4             	movzbl %ah,%edx
  f8a29136:	81 e2 bf 00 00 00    	and    $0xbf,%edx
  	struct iwl_cmd *cmd;

  	/* If a Tx command is being handled and it isn't in the actual
  	 * command queue then there a command routing bug has been introduced
  	 * in the queue management code. */
  	if (WARN(txq_id != IWL_CMD_QUEUE_NUM,
  f8a2913c:	83 fa 04             	cmp    $0x4,%edx
  f8a2913f:	0f 84 d7 01 00 00    	je     f8a2931c <iwl_tx_cmd_complete+0x203>
  f8a29145:	0f b6 46 04          	movzbl 0x4(%esi),%eax
  f8a29149:	50                   	push   %eax
  f8a2914a:	52                   	push   %edx
  f8a2914b:	68 72 21 00 00       	push   $0x2172
  f8a29150:	68 ac 04 00 00       	push   $0x4ac
  f8a29155:	68 9b 21 00 00       	push   $0x219b
*f8a2915a:	e8 fc ff ff ff       	call   f8a2915b <iwl_tx_cmd_complete+0x42> <--- causing instruction
  		 "wrong command queue %d, command id 0x%X\n", txq_id, pkt->hdr.cmd))
  		return;
  f8a2915f:	83 c4 14             	add    $0x14,%esp
  f8a29162:	e9 cc 01 00 00       	jmp    f8a29333 <iwl_tx_cmd_complete+0x21a>
  	/* This is for scan command, the big buffer at end of command array */
  	if (is_huge)
  		return q->n_window;	/* must be power of 2 */

  	/* Otherwise, use normal size buffers */
  	return index & (q->n_window - 1);
  f8a29167:	48                   	dec    %eax
  f8a29168:	22 45 d7             	and    -0x29(%ebp),%al

  	cmd_index = get_cmd_index(&priv->txq[IWL_CMD_QUEUE_NUM].q, index, huge);




Source disassembly for issue 9:
  		radeon_write_agp_location(dev_priv,
  e012abec:	8b 43 34             	mov    0x34(%ebx),%eax     |  %ebx = dd8a9000
  e012abef:	31 c9                	xor    %ecx,%ecx           |  %ecx => dd8a9000
  e012abf1:	8d 50 ff             	lea    -0x1(%eax),%edx
  e012abf4:	03 53 30             	add    0x30(%ebx),%edx     |  %ebx = dd8a9000
  e012abf7:	c1 e8 10             	shr    $0x10,%eax
  e012abfa:	66 31 d2             	xor    %dx,%dx
  e012abfd:	09 c2                	or     %eax,%edx
  e012abff:	89 d8                	mov    %ebx,%eax           |  %ebx = dd8a9000
  e012ac01:	e8 fc ff ff ff       	call   e012ac02 <radeon_cp_init_ring_buffer+0x6d>
  			     (((dev_priv->gart_vm_start - 1 +
  				dev_priv->gart_size) & 0xffff0000) |
  			      (dev_priv->gart_vm_start >> 16)), 0);

  		ring_start = (dev_priv->cp_ring->offset
  e012ac06:	8b 83 cc 00 00 00    	mov    0xcc(%ebx),%eax     |  %ebx = dd8a9000
  e012ac0c:	8b 53 34             	mov    0x34(%ebx),%edx     |  %ebx = dd8a9000
  e012ac0f:	03 10                	add    (%eax),%edx
  e012ac11:	8b 86 70 02 00 00    	mov    0x270(%esi),%eax    |  %esi = dd87b000
  e012ac17:	2b 50 44             	sub    0x44(%eax),%edx
  e012ac1a:	eb 14                	jmp    e012ac30 <radeon_cp_init_ring_buffer+0x9b>
  			      - dev->agp->base
  			      + dev_priv->gart_vm_start);
  	} else
  #endif
  		ring_start = (dev_priv->cp_ring->offset
  e012ac1c:	8b 83 cc 00 00 00    	mov    0xcc(%ebx),%eax     |  %ebx = dd8a9000  %eax => 0
  e012ac22:	8b 53 34             	mov    0x34(%ebx),%edx     |  %ebx = dd8a9000  %edx => 0
*e012ac25:	03 10                	add    (%eax),%edx         |  %eax = 0  %edx = 0 <--- faulting instruction
  e012ac27:	8b 86 80 02 00 00    	mov    0x280(%esi),%eax
  e012ac2d:	2b 50 04             	sub    0x4(%eax),%edx
  build_mmio_read(__readw, "w", unsigned short, "=r", )
  build_mmio_read(__readl, "l", unsigned int, "=r", )

  build_mmio_write(writeb, "b", unsigned char, "q", :"memory")
  build_mmio_write(writew, "w", unsigned short, "r", :"memory")
  build_mmio_write(writel, "l", unsigned int, "r", :"memory")
  e012ac30:	8b 83 74 03 00 00    	mov    0x374(%ebx),%eax
  e012ac36:	8b 40 10             	mov    0x10(%eax),%eax
  e012ac39:	05 00 07 00 00       	add    $0x700,%eax
  e012ac3e:	89 10                	mov    %edx,(%eax)
  { asm volatile("mov" size " %0,%1": :reg (val), \
  "m" (*(volatile type __force *)addr) barrier); }

  build_mmio_read(readb, "b", unsigned char, "=q", :"memory")




Source disassembly for issue 10:
  			for (i = 0; i < dev->num_tx_queues; i++) {
  c063fdb8:	46                   	inc    %esi
  c063fdb9:	3b 75 b0             	cmp    -0x50(%ebp),%esi
  c063fdbc:	72 e9                	jb     c063fda7 <dev_watchdog+0x7d>
  c063fdbe:	eb 59                	jmp    c063fe19 <dev_watchdog+0xef>
  					some_queue_stopped = 1;
  					break;
  				}
  			}

  			if (some_queue_stopped &&
  c063fdc0:	8b 15 00 3b 80 c0    	mov    0xc0803b00,%edx
  c063fdc6:	8b 83 20 02 00 00    	mov    0x220(%ebx),%eax
  c063fdcc:	03 83 1c 02 00 00    	add    0x21c(%ebx),%eax
  c063fdd2:	39 d0                	cmp    %edx,%eax
  c063fdd4:	79 43                	jns    c063fe19 <dev_watchdog+0xef>
  			    time_after(jiffies, (dev->trans_start +
  						 dev->watchdog_timeo))) {
  				char drivername[64];
  				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
  c063fdd6:	83 3d 5c 03 97 c0 00 	cmpl   $0x0,0xc097035c
  c063fddd:	75 32                	jne    c063fe11 <dev_watchdog+0xe7>
  c063fddf:	8d 55 b4             	lea    -0x4c(%ebp),%edx
  c063fde2:	b9 40 00 00 00       	mov    $0x40,%ecx
  c063fde7:	89 d8                	mov    %ebx,%eax
  c063fde9:	e8 7a 04 ff ff       	call   c0630268 <netdev_drivername>
  c063fdee:	50                   	push   %eax
  c063fdef:	53                   	push   %ebx
  c063fdf0:	68 f2 b3 7a c0       	push   $0xc07ab3f2
  c063fdf5:	68 db 00 00 00       	push   $0xdb
  c063fdfa:	68 23 b4 7a c0       	push   $0xc07ab423
*c063fdff:	e8 ab cb de ff       	call   c042c9af <warn_slowpath> <--- causing instruction
  c063fe04:	c7 05 5c 03 97 c0 01 	movl   $0x1,0xc097035c
  c063fe0b:	00 00 00
  c063fe0e:	83 c4 14             	add    $0x14,%esp
  				       dev->name, netdev_drivername(dev, drivername, 64));
  				dev->tx_timeout(dev);
  c063fe11:	89 d8                	mov    %ebx,%eax
  c063fe13:	ff 93 cc 02 00 00    	call   *0x2cc(%ebx)
  			}
  			if (!mod_timer(&dev->watchdog_timer,
  c063fe19:	a1 00 3b 80 c0       	mov    0xc0803b00,%eax
  c063fe1e:	03 83 20 02 00 00    	add    0x220(%ebx),%eax
  c063fe24:	e8 05 4f df ff       	call   c0434d2e <round_jiffies>
  c063fe29:	89 c2                	mov    %eax,%edx
  c063fe2b:	8d 83 24 02 00 00    	lea    0x224(%ebx),%eax
  c063fe31:	e8 b4 59 df ff       	call   c04357ea <mod_timer>
  c063fe36:	85 c0                	test   %eax,%eax
  c063fe38:	75 07                	jne    c063fe41 <dev_watchdog+0x117>
   *
   * Atomically increments @v by 1.
   */
  static inline void atomic_inc(atomic_t *v)
  {
  	asm volatile(LOCK_PREFIX "incl %0"
  c063fe3a:	f0 ff 83 80 02 00 00 	lock incl 0x280(%ebx)




Source disassembly for issue 11:
  c04ae56f:	53                   	push   %ebx
  c04ae570:	89 c3                	mov    %eax,%ebx
  	WARN_ON_ONCE(!buffer_uptodate(bh));
  c04ae572:	e8 d8 ed ff ff       	call   c04ad34f <buffer_uptodate>
  c04ae577:	85 c0                	test   %eax,%eax
  c04ae579:	75 22                	jne    c04ae59d <mark_buffer_dirty+0x31>
  c04ae57b:	83 3d 44 04 95 c0 00 	cmpl   $0x0,0xc0950444
  c04ae582:	75 19                	jne    c04ae59d <mark_buffer_dirty+0x31>
  c04ae584:	ba a2 04 00 00       	mov    $0x4a2,%edx
  c04ae589:	b8 18 ee 76 c0       	mov    $0xc076ee18,%eax
*c04ae58e:	e8 92 e6 f7 ff       	call   c042cc25 <warn_on_slowpath> <--- causing instruction
  c04ae593:	c7 05 44 04 95 c0 01 	movl   $0x1,0xc0950444
  c04ae59a:	00 00 00
   * Emit the buffer bitops functions.   Note that there are also functions
   * of the form "mark_buffer_foo()".  These are higher-level functions which
   * do something in addition to setting a b_state bit.
   */
  BUFFER_FNS(Uptodate, uptodate)
  BUFFER_FNS(Dirty, dirty)
  c04ae59d:	89 da                	mov    %ebx,%edx
  c04ae59f:	b8 01 00 00 00       	mov    $0x1,%eax
  c04ae5a4:	e8 37 ed ff ff       	call   c04ad2e0 <constant_test_bit>
  	 * Very *carefully* optimize the it-is-already-dirty case.
  	 *
  	 * Don't let the final "is it dirty" escape to before we
  	 * perhaps modified the buffer.




Source disassembly for issue 12:
   *
   * This function is similar to (but not equivalent to) down().
   */
  void inline __sched mutex_lock(struct mutex *lock)
  {
  c06a801b:	89 e5                	mov    %esp,%ebp
  c06a801d:	53                   	push   %ebx
  c06a801e:	89 c3                	mov    %eax,%ebx           |  %ebx => c
  c06a8020:	83 ec 04             	sub    $0x4,%esp           |  %esp => f6050f48
  	might_sleep();
  c06a8023:	b8 15 79 76 c0       	mov    $0xc0767915,%eax
  c06a8028:	e8 ee ec d7 ff       	call   c0426d1b <__might_sleep>
  c06a802d:	e8 88 fa ff ff       	call   c06a7aba <_cond_resched>
  	/*
  	 * The locking fastpath is the 1->0 transition from
  	 * 'unlocked' into 'locked' state.
  	 */
  	__mutex_fastpath_lock(&lock->count, __mutex_lock_slowpath);
  c06a8032:	89 d8                	mov    %ebx,%eax           |  %ebx = c  %eax => c
*c06a8034:	f0 ff 08             	lock decl (%eax)           |  %eax = c <--- faulting instruction
  c06a8037:	79 05                	jns    c06a803e <mutex_lock+0x29>
  c06a8039:	e8 6f 01 00 00       	call   c06a81ad <__mutex_lock_slowpath>
  }
  c06a803e:	59                   	pop    %ecx
  c06a803f:	5b                   	pop    %ebx
  c06a8040:	5d                   	pop    %ebp
  c06a8041:	c3                   	ret

  c06a8042 <__mutex_lock_common>:
   * Lock a mutex (possibly interruptible), slowpath:
   */
  static inline int __sched
  __mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
  	       	unsigned long ip)
  {
  c06a8042:	55                   	push   %ebp
  c06a8043:	89 e5                	mov    %esp,%ebp
  c06a8045:	57                   	push   %edi
  c06a8046:	56                   	push   %esi
  c06a8047:	53                   	push   %ebx
  c06a8048:	89 c3                	mov    %eax,%ebx
  	struct task_struct *task = current;




Source disassembly for issue 13:
  				       "seq %X\n", *seq, TCP_SKB_CB(skb)->seq);
  				break;
  c065bf6e:	83 c4 0c             	add    $0xc,%esp
  c065bf71:	eb 45                	jmp    c065bfb8 <tcp_recvmsg+0x1fb>
  			}
  			offset = *seq - TCP_SKB_CB(skb)->seq;
  			if (tcp_hdr(skb)->syn)
  c065bf73:	8b 87 94 00 00 00    	mov    0x94(%edi),%eax
  c065bf79:	8a 48 0d             	mov    0xd(%eax),%cl
  c065bf7c:	88 c8                	mov    %cl,%al
  c065bf7e:	83 e0 02             	and    $0x2,%eax
  				offset--;
  c065bf81:	3c 01                	cmp    $0x1,%al
  c065bf83:	83 55 d4 ff          	adcl   $0xffffffff,-0x2c(%ebp)
  			if (offset < skb->len)
  c065bf87:	8b 47 50             	mov    0x50(%edi),%eax
  c065bf8a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  c065bf8d:	0f 82 9b 02 00 00    	jb     c065c22e <tcp_recvmsg+0x471>
  				goto found_ok_skb;
  			if (tcp_hdr(skb)->fin)
  c065bf93:	80 e1 01             	and    $0x1,%cl
  c065bf96:	0f 85 64 04 00 00    	jne    c065c400 <tcp_recvmsg+0x643>
  				goto found_fin_ok;
  			WARN_ON(!(flags & MSG_PEEK));
  c065bf9c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  c065bfa0:	75 0f                	jne    c065bfb1 <tcp_recvmsg+0x1f4>
  c065bfa2:	ba 51 05 00 00       	mov    $0x551,%edx
  c065bfa7:	b8 6e cd 7a c0       	mov    $0xc07acd6e,%eax
*c065bfac:	e8 74 0c dd ff       	call   c042cc25 <warn_on_slowpath> <--- causing instruction
  			skb = skb->next;
  c065bfb1:	8b 3f                	mov    (%edi),%edi
  		} while (skb != (struct sk_buff *)&sk->sk_receive_queue);
  c065bfb3:	3b 7d d8             	cmp    -0x28(%ebp),%edi
  c065bfb6:	75 95                	jne    c065bf4d <tcp_recvmsg+0x190>

  		/* Well, if we have backlog, try to process it now yet. */

  		if (copied >= target && !sk->sk_backlog.tail)
  c065bfb8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  c065bfbb:	39 45 bc             	cmp    %eax,-0x44(%ebp)
  c065bfbe:	7c 0a                	jl     c065bfca <tcp_recvmsg+0x20d>
  c065bfc0:	83 7e 44 00          	cmpl   $0x0,0x44(%esi)
  c065bfc4:	0f 84 7d 04 00 00    	je     c065c447 <tcp_recvmsg+0x68a>
  			break;

  		if (copied) {
  c065bfca:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  c065bfce:	74 59                	je     c065c029 <tcp_recvmsg+0x26c>
  			if (sk->sk_err ||
  c065bfd0:	83 be d8 00 00 00 00 	cmpl   $0x0,0xd8(%esi)
  c065bfd7:	0f 85 6a 04 00 00    	jne    c065c447 <tcp_recvmsg+0x68a>
  c065bfdd:	8a 46 02             	mov    0x2(%esi),%al
  c065bfe0:	3c 07                	cmp    $0x7,%al
  c065bfe2:	0f 84 5f 04 00 00    	je     c065c447 <tcp_recvmsg+0x68a>
  c065bfe8:	f6 46 24 01          	testb  $0x1,0x24(%esi)
  c065bfec:	0f 85 55 04 00 00    	jne    c065c447 <tcp_recvmsg+0x68a>
  c065bff2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  c065bff6:	0f 84 4b 04 00 00    	je     c065c447 <tcp_recvmsg+0x68a>
  c065bffc:	64 a1 00 30 87 c0    	mov    %fs:0xc0873000,%eax


