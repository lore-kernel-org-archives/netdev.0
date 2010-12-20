From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 11:58:55 +0000
Message-ID: <20101220115855.GD7977@ff.dom.local>
References: <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com> <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com> <1292836097.2800.3.camel@edumazet-laptop> <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com> <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local> <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:54344 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333Ab0LTL66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 06:58:58 -0500
Received: by fxm18 with SMTP id 18so2927573fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 03:58:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101220111141.GC7977@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 11:11:41AM +0000, Jarek Poplawski wrote:
> To tell the truth, Changli could assume we don't need to tell anything,
> because this mirred skb is almost not shared (except the refcount ;-).

Btw, since there was ifb involved, I doubt this skb could hit ixgbe
xmit before unsharing, and patching the driver could matter. Anyway,
Changli, I guess, Pawel needs some instructions on this last patch?

Jarek P.
