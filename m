From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: fix strlen() usage
Date: Mon, 12 Jul 2010 20:34:40 -0700 (PDT)
Message-ID: <20100712.203440.35813617.davem@davemloft.net>
References: <20100710143111.GA19184@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, shemminger@vyatta.com, hohndel@infradead.org,
	jkosina@suse.cz, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753467Ab0GMDeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:34:25 -0400
In-Reply-To: <20100710143111.GA19184@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 10 Jul 2010 16:31:11 +0200

> There was a missing "else" statement so the original code overflowed if
> ->master->name was too long.  Also the ->slave and ->master buffers can
> hold names with 9 characters and a NULL so I cleaned it up to allow
> another character.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
