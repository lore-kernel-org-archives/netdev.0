From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix possible circular locking dependency
Date: Thu, 22 Oct 2009 18:28:44 -0700 (PDT)
Message-ID: <20091022.182844.11139590.davem@davemloft.net>
References: <1256202424-28314-1-git-send-email-xtfeng@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, isdn4linux@listserv.isdn4linux.de,
	tilman@imap.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xtfeng@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751053AbZJWB2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 21:28:21 -0400
In-Reply-To: <1256202424-28314-1-git-send-email-xtfeng@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <xtfeng@gmail.com>
Date: Thu, 22 Oct 2009 17:07:04 +0800

> There's a circular locking dependency:
 ...
>  We don't need to lock nd->queue->xmit_lock to protect single
> isdn_net_lp_busy(). This can fix above lockdep warnings.
> 
> Reported-and-tested-by: Tilman Schmidt <tilman@imap.cc>
> Signed-off-by: Xiaotian Feng <xtfeng@gmail.com>

Applied, thanks.
