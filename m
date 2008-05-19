From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6][NETNS]: Register net/core/ sysctls at
 read-only root.
Date: Mon, 19 May 2008 13:53:50 -0700 (PDT)
Message-ID: <20080519.135350.52469858.davem@davemloft.net>
References: <4831A1D6.4090503@openvz.org>
	<4831A2D5.8060503@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56342
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756421AbYESUxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:53:55 -0400
In-Reply-To: <4831A2D5.8060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 May 2008 19:55:01 +0400

> Most of the net/core/xxx sysctls are read-only now, but this
> goal is achieved with excessive memory consumption in each
> namespace - the whole table is cloned and most of the entries
> in it are ~= 0222.
> 
> Split it into two parts and register (the largest) one at the
> read-only root.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
