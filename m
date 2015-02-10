From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH] rds: rds_cong_queue_updates needs to defer the
 congestion update transmission
Date: Tue, 10 Feb 2015 11:56:38 -0500
Message-ID: <20150210165638.GR337@oracle.com>
References: <20150210142214.GO337@oracle.com>
 <E0CB7D17-5ACB-4860-847E-BB0C01CBB65A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chien Yen <chien.yen@oracle.com>, davem@davemloft.net,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E0CB7D17-5ACB-4860-847E-BB0C01CBB65A@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/10/15 11:50), Chuck Lever wrote:
> > 
> > This patch fixes a sock_lock deadlock in the rds_cong_queue_update path.
> 
> Note that the deadlock appears to exist only with TCP transports.
> 

True, but the patch does no harm to IB: this actually only reverts 
the change from commit 2fa57129d.

I could update the comment to note that this is only true for TCP
transports. Do you think that would help?

--Sowmini
