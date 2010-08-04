From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 4 Aug 2010 10:25:35 -0700
Message-ID: <20100804102535.37bd94c4@nehalam>
References: <E1OgbTZ-0006nb-00.xeb-mail-ru@f279.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56205 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759Ab0HDRZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 13:25:44 -0400
In-Reply-To: <E1OgbTZ-0006nb-00.xeb-mail-ru@f279.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Aug 2010 14:45:33 +0400
xeb@mail.ru wrote:

> +static DEFINE_RWLOCK(chan_lock);

A reader-writer lock is going to be slower than a spin lock
(or RCU) for this. IF possible, could you use RCU?

-- 
