From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] vxlan updates
Date: Tue, 14 Jan 2014 23:39:37 -0800 (PST)
Message-ID: <20140114.233937.101811511088512396.davem@davemloft.net>
References: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaAOHjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:39:37 -0500
In-Reply-To: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 13 Jan 2014 18:41:18 +0100

> Did the split into two patches upon request from Cong Wang.
> 
> Changelog:
> 
>  v1->v2:
>   - Removed BUG_ON as it's not needed.
>  v2->v3:
>   - Removed dev->reg_state check for netns.
>  v3->v4:
>   - Removed list_del(), we seem to do it in some places and
>     in some others not; we agreed it's not really necessary.
>   - Split patch into 2 patches, notifier part and module
>     unload cleanup part.

Series applied, thanks Daniel.
