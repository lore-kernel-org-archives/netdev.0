From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 23 Sep 2008 10:27:10 +0400
Message-ID: <20080923062709.GA7886@2ka.mipt.ru>
References: <20080922070425.GA14572@2ka.mipt.ru> <E1Khzut-0006lv-Co@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johaahn@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:54998 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbYIWG2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 02:28:03 -0400
Content-Disposition: inline
In-Reply-To: <E1Khzut-0006lv-Co@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:54:27PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> I think this dicussion is moot since the only time you want to use
> sendfile is for bulk transfers and these days anybody designing new
> applications that does bulk transfers over UDP should be taken out
> and shot.

One can protect himself pointing how slow may be memory bus in some
hardware setup, which completely does not allow to perform any copy.

-- 
	Evgeniy Polyakov
