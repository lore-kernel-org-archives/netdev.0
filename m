From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netback: don't store invalid vif pointer
Date: Tue, 09 Dec 2014 18:30:25 -0500 (EST)
Message-ID: <20141209.183025.2098328465942240354.davem@davemloft.net>
References: <5486EF48020000780004E1B8@mail.emea.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@eu.citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbaLIXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:30:26 -0500
In-Reply-To: <5486EF48020000780004E1B8@mail.emea.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 09 Dec 2014 11:47:04 +0000

> When xenvif_alloc() fails, it returns a non-NULL error indicator. To
> avoid eventual races, we shouldn't store that into struct backend_info
> as readers of it only check for NULL.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Applied, thanks.
