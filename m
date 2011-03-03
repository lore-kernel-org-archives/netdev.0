From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] bonding: move procfs into bond_procfs.c
Date: Wed, 02 Mar 2011 22:17:07 -0800 (PST)
Message-ID: <20110302.221707.260068518.davem@davemloft.net>
References: <1298896204-6521-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298896204-6521-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 28 Feb 2011 20:30:04 +0800

> bond_main.c is bloating, separate the procfs code out,
> move them to bond_procfs.c
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Please use Makefile rules to conditionally compile the new bond_procfs.o
file, instead of wrapping almost the entire file with an ifdef.

Put the dummy no-PROC_FS function stubs, as inlines, in bonding.h

Thanks!
