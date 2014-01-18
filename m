From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: fix per-cpu helper usage
Date: Fri, 17 Jan 2014 17:52:59 -0800 (PST)
Message-ID: <20140117.175259.1030142896492431310.davem@davemloft.net>
References: <1389887688-55632-1-git-send-email-gerald.schaefer@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidshan@tencent.com, cl@linux.com,
	venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, frank.blaschka@de.ibm.com,
	sebott@linux.vnet.ibm.com
To: gerald.schaefer@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389887688-55632-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Date: Thu, 16 Jan 2014 16:54:48 +0100

> commit ae4b46e9d "net: rds: use this_cpu_* per-cpu helper" broke per-cpu
> handling for rds. chpfirst is the result of __this_cpu_read(), so it is
> an absolute pointer and not __percpu. Therefore, __this_cpu_write()
> should not operate on chpfirst, but rather on cache->percpu->first, just
> like __this_cpu_read() did before.
> 
> Cc: <stable@vger.kernel.org> # 3.8+
> Signed-off-byd Gerald Schaefer <gerald.schaefer@de.ibm.com>

Applied and queued up for -stable, thanks.
