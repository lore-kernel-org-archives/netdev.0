From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH 1/2] net/rds: RDS-TCP: Always create a new rds_sock for
 an incoming connection.
Date: Mon, 4 May 2015 15:29:08 -0400
Message-ID: <20150504192908.GC26844@oracle.com>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
 <cover.1430421231.git.sowmini.varadhan@oracle.com>
 <c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
 <20150504.144720.2228274897975931117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150504.144720.2228274897975931117.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (05/04/15 14:47), David Miller wrote:
> 
> I think adding 64K of data to this module just to solve this rare
> issue is excessive.

I'd based that number mostly as a heuristic based on rds_conn_hash[].
Any suggestions for what's reasonable? 8K? Less?
(BTW, I think that should be 32K, or am I mis-counting?)

> Furthermore I don't see any locking protecting the hash table nor
> the RDS socket linkage into that table.

yes, I missed that, I'll fix that in v2.

--Sowmini
