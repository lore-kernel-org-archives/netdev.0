From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "sit: stateless autoconf for isatap"
Date: Sat, 26 Sep 2009 20:28:30 -0700 (PDT)
Message-ID: <20090926.202830.40709341.davem@davemloft.net>
References: <1253977393-7757-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.org
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753166AbZI0D2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 23:28:11 -0400
In-Reply-To: <1253977393-7757-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Sat, 26 Sep 2009 17:03:13 +0200

> This reverts commit 645069299a1c7358cf7330afe293f07552f11a5d.
> 
> While the code does not actually break anything, it does not completely follow
> RFC5214 yet. After talking back with Fred L. Templin, I agree that completing the
> ISATAP specific RS/RA code, would pollute the kernel a lot with code that is better
> implemented in userspace.
> 
> The kernel should not send RS packages for ISATAP at all.
> 
> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
> Acked-by: Fred L. Templin <Fred.L.Templin@boeing.com>

Applied, thanks.
