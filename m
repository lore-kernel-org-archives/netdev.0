From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 03:51:44 -0700 (PDT)
Message-ID: <20070618.035144.64026005.davem@davemloft.net>
References: <20070618103241.GX521@postel.suug.ch>
	<20070618104059.GY521@postel.suug.ch>
	<E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762130AbXFRKv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 06:51:26 -0400
In-Reply-To: <E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 12:47:17 +0200

> but it's not as if it's really going to affect performance
> in real cases.

Since these circumstances are creatable by any user, we have
to consider the cases caused by malicious entities.
