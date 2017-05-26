From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] nfp: devlink port implementation
Date: Fri, 26 May 2017 11:00:33 -0400 (EDT)
Message-ID: <20170526.110033.1506176237319077411.davem@davemloft.net>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940657AbdEZPAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 11:00:34 -0400
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 26 May 2017 01:03:30 -0700

> This series adds basic devlink support.  The operations we can perform
> are port show and port split/unsplit.
> 
> v2:
> Register devlink first, and then register all the ports.  Port {,un}split
> searches the port list, which is protected by a mutex.  If port split
> is requested before ports are registered we will simply not find the port
> and return -EINVAL.

Great, I'll give Jiri a chance to review this.
