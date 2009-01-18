From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: net_namespace, fix lock imbalance
Date: Sat, 17 Jan 2009 23:08:55 -0800 (PST)
Message-ID: <20090117.230855.174885754.davem@davemloft.net>
References: <1232210832-30041-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	adobriyan@gmail.com
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756077AbZARHIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:08:53 -0500
In-Reply-To: <1232210832-30041-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Sat, 17 Jan 2009 17:47:12 +0100

> register_pernet_gen_subsys omits mutex_unlock in one fail path.
> Fix it.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied, thanks.
