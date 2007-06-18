From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 12:55:24 +0200
Message-ID: <E1I0EtI-0007Ma-00@dorka.pomaz.szeredi.hu>
References: <20070618103241.GX521@postel.suug.ch>
	<20070618104059.GY521@postel.suug.ch>
	<E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu> <20070618.035144.64026005.davem@davemloft.net>
Cc: tgraf@suug.ch, akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:42358 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759723AbXFRK4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 06:56:05 -0400
In-reply-to: <20070618.035144.64026005.davem@davemloft.net> (message from
	David Miller on Mon, 18 Jun 2007 03:51:44 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > but it's not as if it's really going to affect performance
> > in real cases.
> 
> Since these circumstances are creatable by any user, we have
> to consider the cases caused by malicious entities.

OK.  But then the whole gc thing is already broken, since a user can
DoS socket creation/destruction.

I'm all for fixing this gc mess that we have now.  But please don't
expect me to be the one who's doing it.

Miklos
