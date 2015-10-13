From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] RDS: Invoke ->laddr_check() in rds_bind() for
 explicitly bound transports.
Date: Tue, 13 Oct 2015 04:23:08 -0700 (PDT)
Message-ID: <20151013.042308.2015873034325925155.davem@davemloft.net>
References: <20151011204603.GA14646@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151011204603.GA14646@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sun, 11 Oct 2015 16:46:03 -0400

> The IP address passed to rds_bind() should be vetted by the
> transport's ->laddr_check() for a previously bound transport.
> This needs to be done to avoid cases where, for example,
> the application has asked for an IB transport,
> but the IP address passed to bind is only usable on
> ethernet interfaces.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied.
