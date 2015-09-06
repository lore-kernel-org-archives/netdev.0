From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] RDS: rds_conn_lookup() should factor in the
 struct net for a match
Date: Sat, 05 Sep 2015 22:05:18 -0700 (PDT)
Message-ID: <20150905.220518.45486814032088496.davem@davemloft.net>
References: <20150903202452.GJ17626@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com,
	ajaykumar.hotchandani@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbIFFFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 01:05:19 -0400
In-Reply-To: <20150903202452.GJ17626@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 3 Sep 2015 16:24:52 -0400

> 
> Only return a conn if the rds_conn_net(conn) matches the struct
> net passed to rds_conn_lookup().
> 
> Fixes: 467fa15356ac ("RDS-TCP: Support multiple RDS-TCP listen endpoints,
>        one per netns.")
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied.
