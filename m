From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Fix NULL pointer dereference in DAT hash
 collision avoidance
Date: Wed, 13 Feb 2013 13:36:09 -0500 (EST)
Message-ID: <20130213.133609.1664152397252172830.davem@davemloft.net>
References: <1360664325-7323-1-git-send-email-paukoning@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paukoning@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab3BMSgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:36:11 -0500
In-Reply-To: <1360664325-7323-1-git-send-email-paukoning@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pau Koning <paukoning@gmail.com>
Date: Tue, 12 Feb 2013 11:18:45 +0100

> An entry in DAT with the hashed position of 0 can cause a NULL pointer
> dereference when the first entry is checked by batadv_choose_next_candidate.
> This first candidate automatically has the max value of 0 and the max_orig_node
> of NULL. Not checking max_orig_node for NULL in batadv_is_orig_node_eligible
> will lead to a NULL pointer dereference when checking for the lowest address.
> 
> This problem was added in 785ea1144182c341b8b85b0f8180291839d176a8
> ("batman-adv: Distributed ARP Table - create DHT helper functions").
> 
> Signed-off-by: Pau Koning <paukoning@gmail.com>

Applied.
