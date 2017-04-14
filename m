From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 04/22] target: Make use of the new sg_map function at 16
 call sites (fwd)
Date: Fri, 14 Apr 2017 10:09:03 -0600
Message-ID: <f738adf6-0c4a-c808-aefb-6fde7cf8f1ba@deltatee.com>
References: <alpine.DEB.2.20.1704141717510.3212@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all-JC7UmRfGjtg@public.gmane.org, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
 linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
 rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-crypto@vger.
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <alpine.DEB.2.20.1704141717510.3212@hadrien>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Thanks Julia. I missed that and I'll fix it in my series.

Logan

On 14/04/17 09:19 AM, Julia Lawall wrote:
> It looks like &udev->cmdr_lock should be released at line 512 if it has
> not been released otherwise.  The lock was taken at line 438.
> 
> julia
> 
> ---------- Forwarded message ----------
> Date: Fri, 14 Apr 2017 22:21:44 +0800
> From: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> To: kbuild-JC7UmRfGjtg@public.gmane.org
> Cc: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
> Subject: Re: [PATCH 04/22] target: Make use of the new sg_map function at 16
>     call sites
> 
> Hi Logan,
> 
> [auto build test WARNING on scsi/for-next]
> [also build test WARNING on v4.11-rc6]
> [cannot apply to next-20170413]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Logan-Gunthorpe/Introduce-common-scatterlist-map-function/20170414-142518
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi.git for-next
> :::::: branch date: 8 hours ago
> :::::: commit date: 8 hours ago
> 
>>> drivers/target/target_core_user.c:512:2-8: preceding lock on line 438
>    drivers/target/target_core_user.c:512:2-8: preceding lock on line 471
> 
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout 78082134e7afdc59d744eb8d2def5c588e89c378
> vim +512 drivers/target/target_core_user.c
> 
> 7c9e7a6f Andy Grover      2014-10-01  432  				sizeof(struct tcmu_cmd_entry));
> 7c9e7a6f Andy Grover      2014-10-01  433  	command_size = base_command_size
> 7c9e7a6f Andy Grover      2014-10-01  434  		+ round_up(scsi_command_size(se_cmd->t_task_cdb), TCMU_OP_ALIGN_SIZE);
> 7c9e7a6f Andy Grover      2014-10-01  435
> 7c9e7a6f Andy Grover      2014-10-01  436  	WARN_ON(command_size & (TCMU_OP_ALIGN_SIZE-1));
> 7c9e7a6f Andy Grover      2014-10-01  437
> 7c9e7a6f Andy Grover      2014-10-01 @438  	spin_lock_irq(&udev->cmdr_lock);
> 7c9e7a6f Andy Grover      2014-10-01  439
> 7c9e7a6f Andy Grover      2014-10-01  440  	mb = udev->mb_addr;
> 7c9e7a6f Andy Grover      2014-10-01  441  	cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
> 26418649 Sheng Yang       2016-02-26  442  	data_length = se_cmd->data_length;
> 26418649 Sheng Yang       2016-02-26  443  	if (se_cmd->se_cmd_flags & SCF_BIDI) {
> 26418649 Sheng Yang       2016-02-26  444  		BUG_ON(!(se_cmd->t_bidi_data_sg && se_cmd->t_bidi_data_nents));
> 26418649 Sheng Yang       2016-02-26  445  		data_length += se_cmd->t_bidi_data_sg->length;
> 26418649 Sheng Yang       2016-02-26  446  	}
> 554617b2 Andy Grover      2016-08-25  447  	if ((command_size > (udev->cmdr_size / 2)) ||
> 554617b2 Andy Grover      2016-08-25  448  	    data_length > udev->data_size) {
> 554617b2 Andy Grover      2016-08-25  449  		pr_warn("TCMU: Request of size %zu/%zu is too big for %u/%zu "
> 3d9b9555 Andy Grover      2016-08-25  450  			"cmd ring/data area\n", command_size, data_length,
> 7c9e7a6f Andy Grover      2014-10-01  451  			udev->cmdr_size, udev->data_size);
> 554617b2 Andy Grover      2016-08-25  452  		spin_unlock_irq(&udev->cmdr_lock);
> 554617b2 Andy Grover      2016-08-25  453  		return TCM_INVALID_CDB_FIELD;
> 554617b2 Andy Grover      2016-08-25  454  	}
> 7c9e7a6f Andy Grover      2014-10-01  455
> 26418649 Sheng Yang       2016-02-26  456  	while (!is_ring_space_avail(udev, command_size, data_length)) {
> 7c9e7a6f Andy Grover      2014-10-01  457  		int ret;
> 7c9e7a6f Andy Grover      2014-10-01  458  		DEFINE_WAIT(__wait);
> 7c9e7a6f Andy Grover      2014-10-01  459
> 7c9e7a6f Andy Grover      2014-10-01  460  		prepare_to_wait(&udev->wait_cmdr, &__wait, TASK_INTERRUPTIBLE);
> 7c9e7a6f Andy Grover      2014-10-01  461
> 7c9e7a6f Andy Grover      2014-10-01  462  		pr_debug("sleeping for ring space\n");
> 7c9e7a6f Andy Grover      2014-10-01  463  		spin_unlock_irq(&udev->cmdr_lock);
> 7c9e7a6f Andy Grover      2014-10-01  464  		ret = schedule_timeout(msecs_to_jiffies(TCMU_TIME_OUT));
> 7c9e7a6f Andy Grover      2014-10-01  465  		finish_wait(&udev->wait_cmdr, &__wait);
> 7c9e7a6f Andy Grover      2014-10-01  466  		if (!ret) {
> 7c9e7a6f Andy Grover      2014-10-01  467  			pr_warn("tcmu: command timed out\n");
> 02eb924f Andy Grover      2016-10-06  468  			return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
> 7c9e7a6f Andy Grover      2014-10-01  469  		}
> 7c9e7a6f Andy Grover      2014-10-01  470
> 7c9e7a6f Andy Grover      2014-10-01  471  		spin_lock_irq(&udev->cmdr_lock);
> 7c9e7a6f Andy Grover      2014-10-01  472
> 7c9e7a6f Andy Grover      2014-10-01  473  		/* We dropped cmdr_lock, cmd_head is stale */
> 7c9e7a6f Andy Grover      2014-10-01  474  		cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
> 7c9e7a6f Andy Grover      2014-10-01  475  	}
> 7c9e7a6f Andy Grover      2014-10-01  476
> f56574a2 Andy Grover      2014-10-02  477  	/* Insert a PAD if end-of-ring space is too small */
> f56574a2 Andy Grover      2014-10-02  478  	if (head_to_end(cmd_head, udev->cmdr_size) < command_size) {
> f56574a2 Andy Grover      2014-10-02  479  		size_t pad_size = head_to_end(cmd_head, udev->cmdr_size);
> f56574a2 Andy Grover      2014-10-02  480
> 7c9e7a6f Andy Grover      2014-10-01  481  		entry = (void *) mb + CMDR_OFF + cmd_head;
> 7c9e7a6f Andy Grover      2014-10-01  482  		tcmu_flush_dcache_range(entry, sizeof(*entry));
> 0ad46af8 Andy Grover      2015-04-14  483  		tcmu_hdr_set_op(&entry->hdr.len_op, TCMU_OP_PAD);
> 0ad46af8 Andy Grover      2015-04-14  484  		tcmu_hdr_set_len(&entry->hdr.len_op, pad_size);
> 0ad46af8 Andy Grover      2015-04-14  485  		entry->hdr.cmd_id = 0; /* not used for PAD */
> 0ad46af8 Andy Grover      2015-04-14  486  		entry->hdr.kflags = 0;
> 0ad46af8 Andy Grover      2015-04-14  487  		entry->hdr.uflags = 0;
> 7c9e7a6f Andy Grover      2014-10-01  488
> 7c9e7a6f Andy Grover      2014-10-01  489  		UPDATE_HEAD(mb->cmd_head, pad_size, udev->cmdr_size);
> 7c9e7a6f Andy Grover      2014-10-01  490
> 7c9e7a6f Andy Grover      2014-10-01  491  		cmd_head = mb->cmd_head % udev->cmdr_size; /* UAM */
> 7c9e7a6f Andy Grover      2014-10-01  492  		WARN_ON(cmd_head != 0);
> 7c9e7a6f Andy Grover      2014-10-01  493  	}
> 7c9e7a6f Andy Grover      2014-10-01  494
> 7c9e7a6f Andy Grover      2014-10-01  495  	entry = (void *) mb + CMDR_OFF + cmd_head;
> 7c9e7a6f Andy Grover      2014-10-01  496  	tcmu_flush_dcache_range(entry, sizeof(*entry));
> 0ad46af8 Andy Grover      2015-04-14  497  	tcmu_hdr_set_op(&entry->hdr.len_op, TCMU_OP_CMD);
> 0ad46af8 Andy Grover      2015-04-14  498  	tcmu_hdr_set_len(&entry->hdr.len_op, command_size);
> 0ad46af8 Andy Grover      2015-04-14  499  	entry->hdr.cmd_id = tcmu_cmd->cmd_id;
> 0ad46af8 Andy Grover      2015-04-14  500  	entry->hdr.kflags = 0;
> 0ad46af8 Andy Grover      2015-04-14  501  	entry->hdr.uflags = 0;
> 7c9e7a6f Andy Grover      2014-10-01  502
> 26418649 Sheng Yang       2016-02-26  503  	bitmap_copy(old_bitmap, udev->data_bitmap, DATA_BLOCK_BITS);
> 26418649 Sheng Yang       2016-02-26  504
> 3d9b9555 Andy Grover      2016-08-25  505  	/* Handle allocating space from the data area */
> 7c9e7a6f Andy Grover      2014-10-01  506  	iov = &entry->req.iov[0];
> f97ec7db Ilias Tsitsimpis 2015-04-23  507  	iov_cnt = 0;
> e4648b01 Ilias Tsitsimpis 2015-04-23  508  	copy_to_data_area = (se_cmd->data_direction == DMA_TO_DEVICE
> e4648b01 Ilias Tsitsimpis 2015-04-23  509  		|| se_cmd->se_cmd_flags & SCF_BIDI);
> 78082134 Logan Gunthorpe  2017-04-13  510  	if (alloc_and_scatter_data_area(udev, se_cmd->t_data_sg,
> 78082134 Logan Gunthorpe  2017-04-13  511  		se_cmd->t_data_nents, &iov, &iov_cnt, copy_to_data_area))
> 78082134 Logan Gunthorpe  2017-04-13 @512  		return TCM_OUT_OF_RESOURCES;
> 78082134 Logan Gunthorpe  2017-04-13  513
> 7c9e7a6f Andy Grover      2014-10-01  514  	entry->req.iov_cnt = iov_cnt;
> 0ad46af8 Andy Grover      2015-04-14  515  	entry->req.iov_dif_cnt = 0;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
