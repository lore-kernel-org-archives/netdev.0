From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sun, 16 Jul 2006 19:53:16 -0700 (PDT)
Message-ID: <20060716.195316.21925708.davem@davemloft.net>
References: <200607161210.44873.paul.moore@hp.com>
	<20060716.181230.59471240.davem@davemloft.net>
	<200607162242.08622.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@epoch.ncsc.mil, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55748
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932246AbWGQCxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:53:04 -0400
To: paul.moore@hp.com
In-Reply-To: <200607162242.08622.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Sun, 16 Jul 2006 22:42:07 -0400

> Right now I use both the bitmap_walk() and bitmap_setbit() routines
> to deal with both CIPSO tags straight from the sk_buff as well as
> the internal bitmap representation.  Padding out the internal
> bitmaps would require some code changes but there isn't much I can
> do about the packet I don't believe.  True it would probably be okay
> for most packets to assume you could access an entire "long"s worth
> of memory but then again it would only take one evil packet to start
> causing problems ...

The access also has to be long aligned to be valid for
the asm/bitops.h interfaces as well, which is also
problematic for your case I guess.
