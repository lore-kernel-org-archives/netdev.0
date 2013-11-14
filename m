From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 0/6] 6lowpan: udp compression/uncompression fix
Date: Thu, 14 Nov 2013 17:53:39 +0100
Message-ID: <20131114165337.GB2346@omega>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
 <1384445983.28716.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:43876 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757973Ab3KNQxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:53:43 -0500
Received: by mail-bk0-f48.google.com with SMTP id v10so652609bkz.35
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 08:53:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384445983.28716.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 08:19:43AM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-14 at 16:48 +0100, Alexander Aring wrote:
> > The current 6LoWPAN udp compression/uncompression is completely broken.
> > This patch series fix a lot of udp compression/uncompression issues and
> > add support parsing with lowpan_fetch_skb function.
> 
> If its broken, why targeting net-next tree (which is closed BTW ATM) ?
> 
The 6LoWPAN stack still has several unresolved issues (some of which require
more elaborate changes and are therefore net-next material anyway), so
rushing fixes into 'net' wouldn't make a big difference.

- Alex
