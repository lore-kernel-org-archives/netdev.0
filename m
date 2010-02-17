From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] percpu: add __percpu sparse annotations
 to net
Date: Tue, 16 Feb 2010 20:21:02 -0800 (PST)
Message-ID: <20100216.202102.71113896.davem@davemloft.net>
References: <4B7B445A.1080108@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7B445A.1080108@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Wed, 17 Feb 2010 10:20:26 +0900

> Add __percpu sparse annotations to net.
> 
> These annotations are to make sparse consider percpu variables to be
> in a different address space and warn if accessed without going
> through percpu accessors.  This patch doesn't affect normal builds.
> 
> The macro and type tricks around snmp stats make things a bit
> interesting.  DEFINE/DECLARE_SNMP_STAT() macros mark the target field
> as __percpu and SNMP_UPD_PO_STATS() macro is updated accordingly.  All
> snmp_mib_*() users which used to cast the argument to (void **) are
> updated to cast it to (void __percpu **).
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Acked-by: David S. Miller <davem@davemloft.net>

Applied.
