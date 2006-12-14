From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 7/7] Fix unchecked rose_add_loopback_neigh uses
Date: Thu, 14 Dec 2006 15:53:15 -0800 (PST)
Message-ID: <20061214.155315.35358389.davem@davemloft.net>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
	<11661361353489-git-send-email-ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <11661361353489-git-send-email-ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 14 Dec 2006 23:42:13 +0100

> rose_add_loopback_neigh uses kmalloc and the callers were ignoring the
> error value.  Rewrite to let the caller deal with the allocation.  This
> allows the use of static allocation of kmalloc use entirely.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
