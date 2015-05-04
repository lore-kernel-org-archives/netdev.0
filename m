From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/rds: RDS-TCP: Always create a new rds_sock for
 an incoming connection.
Date: Mon, 04 May 2015 16:21:34 -0400 (EDT)
Message-ID: <20150504.162134.1761886048618680717.davem@davemloft.net>
References: <c3c228cbc7f6e4a4cb8e9e0ac400aaf4ed22b927.1430421231.git.sowmini.varadhan@oracle.com>
	<20150504.144720.2228274897975931117.davem@davemloft.net>
	<20150504192908.GC26844@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbEDUVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:21:38 -0400
In-Reply-To: <20150504192908.GC26844@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 4 May 2015 15:29:08 -0400

> On (05/04/15 14:47), David Miller wrote:
>> 
>> I think adding 64K of data to this module just to solve this rare
>> issue is excessive.
> 
> I'd based that number mostly as a heuristic based on rds_conn_hash[].
> Any suggestions for what's reasonable? 8K? Less?
> (BTW, I think that should be 32K, or am I mis-counting?)

No table at all.

There has to be another way to notice this kind of situation, how
for example does NFS or any other sunrpc using service handle this
case?
