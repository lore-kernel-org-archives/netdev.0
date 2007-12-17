From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 18:55:48 -0800
Message-ID: <20071216185548.bc9f1918.akpm@linux-foundation.org>
References: <20071211154835.75ace6bc@freepuppy.rosehill>
	<20071216.133717.202852113.davem@davemloft.net>
	<20071216142915.c120d25c.akpm@linux-foundation.org>
	<20071216.152606.35263254.davem@davemloft.net>
	<4765D4F0.5040202@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	herbert@gondor.apana.org.au, rjw@sisk.pl
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37338 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751227AbXLQC5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 21:57:25 -0500
In-Reply-To: <4765D4F0.5040202@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 20:46:24 -0500 Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Sun, 16 Dec 2007 14:29:15 -0800
> > 
> >> On Sun, 16 Dec 2007 13:37:17 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> >>
> >>> From: Stephen Hemminger <shemminger@linux-foundation.org>
> >>> Date: Tue, 11 Dec 2007 15:48:35 -0800
> >>>
> >>>> Subject: Re: [PATCH] bridge: assign random address
> >>> "bridge" should all-caps and in brackets,
> >> No, "bridge" should not be in [].  Lots of people's patch-receiving scripts
> >> assume that any text in [] is to be removed as the patch is committed.  It
> >> contains text which is only relevant to the particular email which carried
> >> the patch.  Stuff like "patch" and "4/5" and "linux-2.6.23", etc.
> > 
> > I don't use scripts, I edit it by hand.  And when I do ever use
> > scripts I will make sure they accomodate "[$SUBSYSTEM]" format
> > subject lines, you can be sure.
> > 
> > And you can even make those scripts happy by doing:
> > 
> > [Patch 1/7] [SUBSYSTEM]: Foo bar baz...
> 
> The most popular tool is git-am, which I and many others use.
> 
> git-am will snip "[SUBSYSTEM]" in the example that you give.
> 
> Until Linus's official mail import tool (git-am) changes, I agree with 
> Andrew -- since Andrew is simply describing the de facto standard as it 
> exists today:  [] gets eaten.

I didn't know that.

> That's why documentation like Documentation/SubmittingPatches and 
> http://linux.yyz.us/patch-format.html indicate "subsystem: " rather than 
> "[SUBSYSTEM]":  it's compatible with Linus's widely used mail import tool.
> 

People are tossing all sorts of metadata into [] nowadays...

grep '^Subject:' lkmo-folder | grep '\[.*\[' | grep -v Re:

says stuff like

Subject: [PATCH 5/7] Security: Change current->fs[ug]id to current_fs[ug]id()
Subject: [PATCH 00/28] Permit filesystem local caching [try #2]
Subject: [PATCH 04/28] KEYS: Add keyctl function to get a security label [try
Subject: [PATCH 05/28] Security: Change current->fs[ug]id to
Subject: [PATCH 02/28] KEYS: Check starting keyring as part of search [try #2]
Subject: [PATCH 21/28] NFS: Display local caching state [try #2]
Subject: [PATCH 17/28] CacheFiles: Export things for CacheFiles [try #2]
Subject: [PATCH 13/28] CacheFiles: Add missing copy_page export for ia64 [try
Subject: [PATCH 19/28] NFS: Use local caching [try #2]
Subject: [PATCH 12/28] FS-Cache: Generic filesystem caching facility [try #2]
Subject: [PATCH 23/28] AFS: Add TestSetPageError() [try #2]
Subject: [PATCH 22/28] fcrypt endianness misannotations [try #2]
Subject: [PATCH 26/28] AF_RXRPC: Save the operation ID for debugging [try #2]
Subject: [PATCH 25/28] AFS: Improve handling of a rejected writeback [try #2]
Subject: [PATCH 27/28] AFS: Implement shared-writable mmap [try #2]
Subject: [PATCH 28/28] FS-Cache: Make kAFS use FS-Cache [try #2]
Subject: [RFC] [PATCH] A clean approach to writeout throttling
Subject: [RFC][POWERPC] Provide a way to protect 4k subpages when
Subject: [PATCH 2/3] [PATCH] unify common parts of segment.h
Subject: [PATCH 1/3] [PATCH] put get_kernel_rpl in a common location
Subject: [PATCH 3/3] [PATCH] remove arch specific segment headers
Subject: [patch 2.6.24-rc4-mm 1/6] gpiolib: add gpio_desc[]
Subject: [PATCH][SCSI] hptiop: add more adapter models and other fixes
Subject: [PATCH][for -mm] fix accounting in vmscan.c for memory controller
Subject: [DOC][for -mm] update Documentation/controller/memory.txt
Subject: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Subject: RE: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Subject: RE: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Subject: [PATCH 7/7] [NETDEV]: myri10ge Fix possible causing oops of net_rx_action
Subject: [PATCH 4/7] [NETDEV]: ixgbe Fix possible causing oops of net_rx_action
Subject: [PATCH 5/7] [NETDEV]: e100 Fix possible causing oops of net_rx_action
Subject: [PATCH 3/7] [NETDEV]: ixgb Fix possible causing oops of net_rx_action
Subject: [PATCH 1/7] [NETDEV]: e1000 Fix possible causing oops of net_rx_action
Subject: [PATCH 2/7] [NETDEV]: e1000e Fix possible causing oops of net_rx_action
Subject: [PATCH 6/7] [NETDEV]: tehuti Fix possible causing oops of net_rx_action
Subject: [PATCH][SCSI] resend: hptiop: add more adapter models and other fixes
Subject: [PATCH/RFC] [POWERPC] Add fixed-phy support for fs_enet
Subject: [PATCH][NETDEV]: remove netif_running() check from myri10ge_poll()
Subject: [RFC] [PATCH -mm] agp: remove uid comparison as security check
Subject: [RFC] [PATCH -mm] agp: remove uid comparison as security check
Subject: [RFC] [PATCH -mm] reiser4: replace uid==0 check with capability
Subject: [RFC] [PATCH -mm] reiser4: replace uid==0 check with capability
Subject: [RFC] [PATCH -mm] oom_kill: remove uid==0 checks
Subject: [RFC] [PATCH -mm] oom_kill: remove uid==0 checks
Subject: [PATCH][MMC] Fix wrong EXT_CSD_REV handling
Subject: [PATCH] x86: move interrupts[] to .rodata/.init.data
Subject: RE: [PATCH 1/7] [NETDEV]: e1000 Fix possible causing oops of net_rx_action
Subject: [PATCH][KJ] 8250: remove unnecessary variable tmout from  wait_for_xmitr()
Subject: [PATCH][rewrite with goto error handling] Bluetooth: hci_sysfs
Subject: [RFC][PATCH] fix bus error when trying to access anon & shared page created by mremap()[BUG:8691]
Subject: [RFC] [patch 2/2] Refuse kprobe insertion on __init section code
Subject: [RFC] [patch 1/2] add non_init_kernel_text_address
Subject: [PATCH] [TCP]: Fix fack_count miscountings (multiple places)
Subject: RE: [i2c] [PATCH 2.6.24-rc4-mm 1/2] gpiolib: basic support for 16-bit PCA9539 GPIO expander[
Subject: [PATCH][RT] 2.6.24-rc5-rt1 drivers/dma/ioat_dma.c compile fix


Kinda funny.  I (and I bet lots of others) spend a lot of time fixing,
cleaning up and totally rewriting patch titles.

