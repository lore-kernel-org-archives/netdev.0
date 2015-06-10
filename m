From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fs_enet: Disable NETIF_F_SG feature for
 Freescale MPC5121
Date: Tue, 09 Jun 2015 17:14:41 -0700 (PDT)
Message-ID: <20150609.171441.861174213383180358.davem@davemloft.net>
References: <1433894262-28900-1-git-send-email-alex.popov@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alex.popov@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbbFJAOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 20:14:44 -0400
In-Reply-To: <1433894262-28900-1-git-send-email-alex.popov@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Popov <alex.popov@linux.com>
Date: Wed, 10 Jun 2015 02:57:42 +0300

> skb_copy_from_linear_data() which doesn't work well for non-linear sk_buff:

The correct fix is to use an SKB copy routine which can
handle non-linear data.
