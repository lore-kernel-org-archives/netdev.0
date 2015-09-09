From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] RDS: verify the underlying transport exists before
 creating a connection
Date: Wed, 09 Sep 2015 12:38:51 -0700 (PDT)
Message-ID: <20150909.123851.1753247693899572461.davem@davemloft.net>
References: <1441724020-19035-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441724020-19035-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Tue,  8 Sep 2015 10:53:40 -0400

> There was no verification that an underlying transport exists when creating
> a connection, this would cause dereferencing a NULL ptr.
> 
> It might happen on sockets that weren't properly bound before attempting to
> send a message, which will cause a NULL ptr deref:
 ...
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied.
