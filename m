From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sun, 25 Apr 2010 00:38:34 -0700 (PDT)
Message-ID: <20100425.003834.147984813.davem@davemloft.net>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
	<20100424.225128.52181685.davem@davemloft.net>
	<z2h412e6f7f1004242348ibd5f96a2i7cd0557c37bb0921@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104Ab0DYHi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 03:38:29 -0400
In-Reply-To: <z2h412e6f7f1004242348ibd5f96a2i7cd0557c37bb0921@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 25 Apr 2010 14:48:49 +0800

> Are they always aligned to 64-bit boundary? I don't think so.

If not than TCP stack should be crashing for past 15 years.
