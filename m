From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3 1/3] net: netprio: fix files lock and remove
 useless d_path bits
Date: Thu, 16 Aug 2012 15:11:45 -0700 (PDT)
Message-ID: <20120816.151145.1545241222143797093.davem@davemloft.net>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
To: john.r.fastabend@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 14 Aug 2012 15:34:24 -0700

> Add lock to prevent a race with a file closing and also remove
> useless and ugly sscanf code. The extra code was never needed
> and the case it supposedly protected against is in fact handled
> correctly by sock_from_file as pointed out by Al Viro.
> 
> CC: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
