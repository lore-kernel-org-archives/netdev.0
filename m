From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: cleanup: make buffer smaller
Date: Mon, 06 Sep 2010 18:30:20 -0700 (PDT)
Message-ID: <20100906.183020.233685314.davem@davemloft.net>
References: <20100904183303.GN5437@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, tilman@imap.cc, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755690Ab0IGBaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:30:02 -0400
In-Reply-To: <20100904183303.GN5437@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 4 Sep 2010 20:33:03 +0200

> This showed up in my audit because we use strcpy() to copy "ds" into a
> 32 character buffer inside the isdn_tty_dial() function.  But it turns
> out that we only ever use the first 32 characters so it's OK.  I have
> changed the declaration to make the static checkers happy.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
