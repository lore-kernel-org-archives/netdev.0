From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix userspace compilation of ip_tables.h/ip6_tables.h
 in C++ mode
Date: Mon, 01 Oct 2012 00:45:47 -0400 (EDT)
Message-ID: <20121001.004547.291872991703576360.davem@davemloft.net>
References: <20120930231737.GA30637@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120930231737.GA30637@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Sun, 30 Sep 2012 17:17:37 -0600

> The implicit cast from void * is not allowed for C++ compilers, and the
> arithmetic on void * generates warnings in C++ mode.
> 
> $ g++ -c t.cc
> ip_tables.h:221:24: warning: pointer of type 'void *' used in arithmetic
> ip_tables.h:221:24: error: invalid conversion from 'void*' to 'xt_entry_target*'
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Please post netfilter patches to netfilter-devel@vger.kernel.org

Thank you.
