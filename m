From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] RDS: TCP: Enable mprds for rds-tcp
Date: Fri, 15 Jul 2016 11:38:11 -0700 (PDT)
Message-ID: <20160715.113811.2167685346308734765.davem@davemloft.net>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbcGOSiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:38:13 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 14 Jul 2016 03:51:00 -0700

> The third, and final, installment for mprds-tcp changes.
> 
> In Patch 3 of this set, if the transport support t_mp_capable, 
> we hash outgoing traffic across multiple paths.  Additionally, even if 
> the transport is MP capable, we may be peering with some node that does
> not support mprds, or supports a different number of paths. This
> necessitates RDS control plane changes so that both peers agree
> on the number of paths to be used for the rds-tcp connection.
> Patch 3 implements all these changes, which are documented in patch 5
> of the series.
> 
> Patch 1 of this series is a bug fix for a race-condition
> that has always existed, but is now more easily encountered with mprds. 
> Patch 2 is code refactoring. Patches 4 and 5 are Documentation updates.

Series applied, thanks.
