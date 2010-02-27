From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Fri, 26 Feb 2010 16:42:11 -0800
Message-ID: <20100226164211.1a02a31b@nehalam>
References: <20100226153410.GA26419@gondor.apana.org.au>
	<E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49208 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966730Ab0B0AmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 19:42:17 -0500
In-Reply-To: <E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 23:35:15 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> bridge: Add multicast_router sysfs entries
> 
> This patch allows the user to forcibly enable/disable ports as
> having multicast routers attached.  A port with a multicast router
> will receive all multicast traffic.
> 
> The value 0 disables it completely.  The default is 1 which lets
> the system automatically detect the presence of routers (currently
> this is limited to picking up queries), and 2 means that the port
> will always receive all multicast traffic.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


I like the functionality, but don't like users whacking on sysfs
directly. Could you send patches to integrate a user API into
bridge-utils; the utils are at: 
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
