From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/net/eql.c: prevent reading uninitialized
 stack memory
Date: Thu, 16 Sep 2010 21:55:41 -0700 (PDT)
Message-ID: <20100916.215541.257507783.davem@davemloft.net>
References: <1284586984.6275.92.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, stable@kernel.org
To: drosenberg@vsecurity.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284586984.6275.92.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 15 Sep 2010 17:43:04 -0400

> Fixed formatting (tabs and line breaks).
> 
> The EQL_GETMASTRCFG device ioctl allows unprivileged users to read 16
> bytes of uninitialized stack memory, because the "master_name" member of
> the master_config_t struct declared on the stack in eql_g_master_cfg()
> is not altered or zeroed before being copied back to the user.  This
> patch takes care of it.
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

Applied.
