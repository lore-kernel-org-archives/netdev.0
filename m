From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Avoid creating fdb entry with NULL destination
Date: Tue, 17 Sep 2013 20:20:00 -0400 (EDT)
Message-ID: <20130917.202000.1535219653178049055.davem@davemloft.net>
References: <1379445160.21109.29.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	mike.rapoport@ravellosystems.com
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab3IRAUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 20:20:02 -0400
In-Reply-To: <1379445160.21109.29.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 17 Sep 2013 12:12:40 -0700

> Commit afbd8bae9c798c5cdbe4439d3a50536b5438247c 
>    vxlan: add implicit fdb entry for default destination
> creates an implicit fdb entry for default destination. This results 
> in an invalid fdb entry if default destination is not specified.
> For ex: 
>   ip link add vxlan1 type vxlan id 100
> creates the following fdb entry
>   00:00:00:00:00:00 dev vxlan1 dst 0.0.0.0 self permanent
> 
> This patch fixes this issue by creating an fdb entry only if a
> valid default destination is specified.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Looks reasonable, applied, thanks.
