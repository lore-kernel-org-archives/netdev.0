From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] RDS: multiple connection paths for
 scaling
Date: Wed, 15 Jun 2016 00:04:52 -0700 (PDT)
Message-ID: <20160615.000452.1747531928162394383.davem@davemloft.net>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbcFOHE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 03:04:59 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 13 Jun 2016 09:44:25 -0700

 ...
> This patch series lays down the foundational data-structures to support
> mprds in the kernel. It implements the changes to split up the
> rds_connection structure into a common (to all paths) part,
> and a per-path rds_conn_path. All I/O workqs are driven from
> the rds_conn_path. 
> 
> Note that this patchset does not (yet) actually enable multipathing
> for any of the transports; all transports will continue to use a 
> single path with the refactored data-structures. A subsequent patchset
> will  add the changes to the rds-tcp module to actually use mprds
> in rds-tcp.

Series applied, thank you.
