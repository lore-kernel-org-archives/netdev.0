From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hsr: Fix possible leak in 'hsr_get_node_status()'
Date: Thu, 14 Nov 2013 17:26:37 -0500 (EST)
Message-ID: <20131114.172637.288809112911669556.davem@davemloft.net>
References: <1384456378-29970-1-git-send-email-geyslan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@xdin.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geyslan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824Ab3KNW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:26:40 -0500
In-Reply-To: <1384456378-29970-1-git-send-email-geyslan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Geyslan G. Bem" <geyslan@gmail.com>
Date: Thu, 14 Nov 2013 16:12:54 -0300

> If 'hsr_get_node_data()' returns error, going directly to 'fail' label
> doesn't free the memory pointed by 'skb_out'.
> 
> Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>

Looks good, applied, thanks!
