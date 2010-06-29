From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] isdn/gigaset: add a kfree() to error path
Date: Wed, 30 Jun 2010 00:33:11 +0200
Message-ID: <20100629223311.GR19184@bicker>
References: <20100628212046.GM19184@bicker> <4C2A7127.3040609@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51151 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab0F2Wez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:34:55 -0400
Content-Disposition: inline
In-Reply-To: <4C2A7127.3040609@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 12:18:15AM +0200, Tilman Schmidt wrote:
> Dan,
> 
> thanks for your patch. It is quite correct as it stands.
> There is however another problem with that error path, in
> that it also doesn't free the previously allocated channel.
> I prefer not to carry two separate patches for that, so I'm
> replacing your patch with the following augmented patch,
> which I'll submit together with my other pending patches
> for 2.6.36 soon:
> 

Good deal.

Acked-by: Dan Carpenter <error27@gmail.com>

regards,
dan carpenter

