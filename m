From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] vlan: GRO rx statistics
Date: Sun, 15 Nov 2009 21:21:36 -0800 (PST)
Message-ID: <20091115.212136.202646803.davem@davemloft.net>
References: <4AFD8C31.10703@gmail.com>
	<20091114012741.GA18764@gondor.apana.org.au>
	<4B00581C.3060303@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751822AbZKPFVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 00:21:20 -0500
In-Reply-To: <4B00581C.3060303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Nov 2009 20:35:56 +0100

> vlan_hwaccel_do_receive() has no napi context.

But this is a choice :-)  And being able to split up the RX
counters would be another reason to potentially change that
choice.
