From: David Miller <davem@redhat.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 12 Mar 2013 06:49:53 -0400 (EDT)
Message-ID: <20130312.064953.1091536680060355804.davem@redhat.com>
References: <20130312113320.b1f41dcb59baa74a51b064cc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, khlebnikov@openvz.org,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932673Ab3CLKtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 06:49:52 -0400
In-Reply-To: <20130312113320.b1f41dcb59baa74a51b064cc@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 12 Mar 2013 11:33:20 +1100

> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/intel/e1000e/netdev.c between commits 4e0855dff094
> ("e1000e: fix pci-device enable-counter balance") and 66148babe728
> ("e1000e: fix runtime power management transitions") from Linus' tree and
> commit f0ff439872e1 ("e1000e: cleanup CODE_INDENT checkpatch errors")
> from the net-next tree.
> 
> The former removed the line fixed by the latter, so I did that and can
> carry the fix as necessary (no action is required).

I've just merged 'net' into 'net-next' and resolved this merge conflict.
