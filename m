From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net/rds: SOL_RDS socket option to explicitly
 select transport
Date: Sun, 31 May 2015 21:47:41 -0700 (PDT)
Message-ID: <20150531.214741.1556826335549377523.davem@davemloft.net>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 29 May 2015 17:28:06 -0400

> Today the underlying transport (TCP or IB) for a PF_RDS socket is
> implicitly selected based on the local address used to bind(2) the
> PF_RDS socket. This results in some non-deterministic behavior when
> there are un-numbered and IPoIB interfaces sharing the same IP address.
> It also places the constraint that the IB interface must have an IP
> address (and thus, IPoIB) configured on it.
> 
> The non-determinism may be avoided by providing the user-space application
> a socket option that allows it to explicitly select the transport
> prior to bind(2).
> 
> Patch 1 of this series provides the constant definitions needed by
> the application via <linux/rds.h>.
> 
> Patch 2 provides the setsockopt support, and Patch 3 provides the
> getsockopt support.

Seems reasonable, series applied to net-next, thanks.
