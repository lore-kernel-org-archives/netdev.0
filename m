From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] nfp: devlink port implementation
Date: Fri, 26 May 2017 11:02:04 -0400 (EDT)
Message-ID: <20170526.110204.1579570229962355609.davem@davemloft.net>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
        <20170526082532.GC1898@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764176AbdEZPCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 11:02:06 -0400
In-Reply-To: <20170526082532.GC1898@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 May 2017 10:25:32 +0200

> Fri, May 26, 2017 at 10:03:30AM CEST, jakub.kicinski@netronome.com wrote:
>>Hi!
>>
>>This series adds basic devlink support.  The operations we can perform
>>are port show and port split/unsplit.
>>
>>v2:
>>Register devlink first, and then register all the ports.  Port {,un}split
>>searches the port list, which is protected by a mutex.  If port split
>>is requested before ports are registered we will simply not find the port
>>and return -EINVAL.
> 
> Looks fine to me now. Thanks!

Wow, you review stuff fast :-)

Series applied, thanks.
