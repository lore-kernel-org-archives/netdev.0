From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] kernel parameters: introduce "macaddr" to set mac
 address
Date: Tue, 23 Oct 2012 13:20:37 -0400 (EDT)
Message-ID: <20121023.132037.2010164496712539552.davem@davemloft.net>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kristoffer@gaisler.com
To: p.pisati@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056Ab2JWRUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:20:39 -0400
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Pisati <p.pisati@gmail.com>
Date: Tue, 23 Oct 2012 19:15:27 +0200

> In the past drivers grew mechanism to set their own mac address at boot time
> via (usually) a module parameter. Unfortunately every single driver had its
> own naming/implementation and it soon became clear that a generic
> mechanism was needed.
> 
> Introduce "macaddr=", a new kernel parameter to set MAC address using
> netdevice ops (and hence being hardware independent).

Sorry, no, no module parameters.

Run time setting is the only reasonable way to set the MAC address
explicitly.
