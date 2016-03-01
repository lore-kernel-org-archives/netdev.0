From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fix list corruption
Date: Tue, 01 Mar 2016 15:20:05 -0500 (EST)
Message-ID: <20160301.152005.1101376339335232556.davem@davemloft.net>
References: <1456474550-16747-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbcCAUUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:20:06 -0500
In-Reply-To: <1456474550-16747-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 26 Feb 2016 09:15:50 +0100

> Use list_move_tail() to move MAC address entry from list of pending
> to list of active entries. Simple list_add_tail() leaves the entry
> also in the first list, this leads to list corruption.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.
