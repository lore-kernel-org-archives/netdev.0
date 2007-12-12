From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: Display the audited SPI value in host byte order
Date: Wed, 12 Dec 2007 11:10:37 -0800 (PST)
Message-ID: <20071212.111037.88942499.davem@davemloft.net>
References: <20071212190542.20699.96051.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: paul.moore@hp.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071212190542.20699.96051.stgit@flek.americas.hpqcorp.net>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 12 Dec 2007 14:05:42 -0500

> Currently the IPsec protocol SPI values are written to the audit log in
> network byte order which is different from almost all other values which
> are recorded in host byte order.  This patch corrects this inconsistency
> by writing the SPI values to the audit record in host byte order.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied to net-2.6, thanks Paul.
