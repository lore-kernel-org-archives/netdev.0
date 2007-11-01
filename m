From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] Relax the reference counting of init_net_ns
Date: Thu, 01 Nov 2007 00:43:58 -0700 (PDT)
Message-ID: <20071101.004358.43254911.davem@davemloft.net>
References: <4728D54F.2080208@openvz.org>
	<4728D69E.6030808@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754521AbXKAHn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:43:59 -0400
In-Reply-To: <4728D69E.6030808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 22:25:18 +0300

> When the CONFIG_NET_NS is n there's no need in refcounting
> the initial net namespace. So relax this code by making a
> stupid stubs for the "n" case.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
