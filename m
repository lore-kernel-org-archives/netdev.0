From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AX.25: Fix sysctl registration if
 !CONFIG_AX25_DAMA_SLAVE
Date: Tue, 05 Aug 2008 18:47:37 -0700 (PDT)
Message-ID: <20080805.184737.158103058.davem@davemloft.net>
References: <20080805223736.GA16608@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, thomas@osterried.de,
	jann@linux-mips.org, dl5di@gmx.de
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080805223736.GA16608@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 5 Aug 2008 23:37:36 +0100

> Since 49ffcf8f99e8d33ec8afb450956804af518fd788
> setting struct ctl_table.procname = NULL does no longer work as it used to
> the way the AX.25 code is expecting it to resulting in the AX.25 sysctl
> registration code to break if CONFIG_AX25_DAMA_SLAVE was not set as in some
> distribution kernels.  Kernel releases from 2.6.24 are affected.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, and I'll queue it up for -stable too.

Thanks Ralf.
