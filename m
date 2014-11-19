From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4i : Don't block unload/cxgb4 unload when
 remote closes TCP connection
Date: Wed, 19 Nov 2014 16:59:50 -0500 (EST)
Message-ID: <20141119.165950.2141251288119010411.davem@davemloft.net>
References: <1416366591-9699-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	hch@infradead.org, jbottomley@parallels.com, kxie@chelsio.com,
	manojmalviya@chelsio.com
To: anish@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1416366591-9699-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 18 Nov 2014 19:09:51 -0800

> cxgb4i was returning wrong error and not releasing module reference if remote
> end abruptly closed TCP connection. This prevents the cxgb4 network module from
> being unloaded, further affecting other network drivers dependent on cxgb4
> 
> Sending to net as this affects all cxgb4 based network drivers.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thank you.
