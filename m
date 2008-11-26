From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 38/53] netns xfrm: dst garbage-collecting in netns
Date: Tue, 25 Nov 2008 17:37:39 -0800 (PST)
Message-ID: <20081125.173739.81237349.davem@davemloft.net>
References: <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-37-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-38-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752710AbYKZBhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:37:39 -0500
In-Reply-To: <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:10 +0300

> Pass netns pointer to struct xfrm_policy_afinfo::garbage_collect()
> 
> 	[This needs more thoughts on what to do with dst_ops]
> 	[Currently stub to init_net]

Yes, this dst_ops issue has been brought up a few times.

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
