From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: fix definition of 5272 version of
 FEC_X_DES_ACTIVE register
Date: Mon, 06 Jul 2009 18:52:58 -0700 (PDT)
Message-ID: <20090706.185258.163126816.davem@davemloft.net>
References: <200907070123.n671NY36005818@localhost.localdomain>
	<20090706.182704.192109619.davem@davemloft.net>
	<4A52A6CE.6010509@snapgear.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org, s.hauer@pengutronix.de
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753543AbZGGBwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:52:51 -0400
In-Reply-To: <4A52A6CE.6010509@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 07 Jul 2009 11:37:18 +1000

> That is not a cleanup patch. It is a bug fix. You cannot build
> with those ";" in there:

Your commit message could have been more explicit about this.
In fact, your commit message was empty. :-/

I'll move that change over to net-2.6 and apply the bug fix for that
one value as well, but you can avoid these kinds of charades in the
future by writing proper, verbose, commit messages.
