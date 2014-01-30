From: Dave Jones <davej@redhat.com>
Subject: Re: r8169: DMA-API: exceeded 7 overlapping mappings of pfn 943ad
Date: Thu, 30 Jan 2014 16:13:02 -0500
Message-ID: <20140130211302.GB25033@redhat.com>
References: <20140130160113.GA18779@redhat.com>
 <20140130210802.GA3373@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbaA3VNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 16:13:12 -0500
Content-Disposition: inline
In-Reply-To: <20140130210802.GA3373@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 10:08:02PM +0100, Francois Romieu wrote:
 > Dave Jones <davej@redhat.com> :
 > > WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
 > > DMA-API: exceeded 7 overlapping mappings of pfn 943ad
 > > Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_conntrack nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel microcode pcspkr r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit drm_kms_helper drm video backlight
 > > CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0+ #10
 > 
 > Was 59f2e7df574c78e952d79435de3f4867349403aa included in the run ?

yes.

	Dave
