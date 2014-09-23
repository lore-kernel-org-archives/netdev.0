From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] mips: Set CONFIG_NET=y in defconfigs
Date: Tue, 23 Sep 2014 12:02:37 -0400 (EDT)
Message-ID: <20140923.120237.1788295912902036193.davem@davemloft.net>
References: <54218AEF.5090200@suse.cz>
	<1411487044-14071-1-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, rdunlap@infradead.org,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-mips@linux-mips.org
To: mmarek@suse.cz
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1411487044-14071-1-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Marek <mmarek@suse.cz>
Date: Tue, 23 Sep 2014 17:44:00 +0200

> Commit 5d6be6a5 ("scsi_netlink : Make SCSI_NETLINK dependent on NET
> instead of selecting NET") removed what happened to be the only instance
> of 'select NET'. Defconfigs that were relying on the select now lack
> networking support.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: linux-mips@linux-mips.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>

On the contrary, since NET was being selected for them indirectly
previously, weren't they depending instead upon NET being enabled?

Likewise for SCSI_NETLINK, SCSI_FC_ATTRS, and whatever was triggering
the select upon them?

I'll remember this as yet another why 'select' is to be avoided at
just about all costs.
