From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] RDS: TCP: HA/Failover fixes
Date: Thu, 17 Nov 2016 13:35:37 -0500 (EST)
Message-ID: <20161117.133537.1135569496092573001.davem@davemloft.net>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com,
        rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754555AbcKQSfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:35:39 -0500
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 16 Nov 2016 13:29:47 -0800

> This series contains a set of fixes for bugs exposed when
> we ran the following in a loop between a test machine pair:
> 
>  while (1); do
>    # modprobe rds-tcp on test nodes
>    # run rds-stress in bi-dir mode between test machine pair 
>    # modprobe -r rds-tcp on test nodes
>  done
> 
> rds-stress in bi-dir mode will cause both nodes to initiate
> RDS-TCP connections at almost the same instant, exposing the 
> bugs fixed in this series. 
> 
> Without the fixes, rds-stress reports sporadic packet drops,
> and packets arriving out of sequence. After the fixes,we have
> been able to run the  test overnight, without any issues.
> 
> Each patch has a detailed description of the root-cause fixed
> by the patch.

Series applied, thank you.
