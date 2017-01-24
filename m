From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] net: Fix oops on state free after lwt
 module unload
Date: Tue, 24 Jan 2017 16:21:56 -0500 (EST)
Message-ID: <20170124.162156.732256204420312210.davem@davemloft.net>
References: <1484958086-6151-1-git-send-email-rshearma@brocade.com>
        <1485275208-31702-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
        roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAXVXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:23:08 -0500
In-Reply-To: <1485275208-31702-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Tue, 24 Jan 2017 16:26:46 +0000

> An oops is seen in lwtstate_free after an lwt ops module has been
> unloaded. This patchset fixes this by preventing modules implementing
> lwtunnel ops from being unloaded whilst there's state alive using
> those ops. The first patch adds fills in a new owner field in all lwt
> ops and the second patch makes use of this to reference count the
> modules as state is built and destroyed using them.
> 
> Changes in v3:
>  - don't put module reference if try_module_get fails on building state
> 
> Changes in v2:
>  - specify module owner for all modules as suggested by DaveM
>  - reference count all modules building lwt state, not just those ops
>    implementing destroy_state, as also suggested by DaveM.
>  - rebased on top of David Ahern's lwtunnel changes

Applied and queued up for -stable.

Thanks.
