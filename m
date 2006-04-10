From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 09:46:30 -0400
Message-ID: <20060410134625.GA25360@tuxdriver.com>
References: <20060410040120.GA4860@ens-lyon.fr> <200604100607.33362.mb@bu3sch.de> <20060410042228.GN27596@ens-lyon.fr> <200604100628.01483.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Boissinot <benoit.boissinot@ens-lyon.org>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751138AbWDJNq4@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200604100628.01483.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2006 at 06:28:00AM +0200, Michael Buesch wrote:

> To summerize: I actually added these messages, because people were
> hitting "this does not work with >1G" issues and did not get an error message.
> So I decided to insert warnings until the issue is fixed inside the arch code.
> I will remove them once the issue is fixed.

This sounds like the same sort of problems w/ the b44 driver.
I surmise that both use the same (broken) DMA engine from Broadcom.

Unfortunately, I don't know of any good solution to this.  There are
a few hacks in b44 that deal with the issue.  I don't like them,
although I am the perpetrator of at least one of them.  It might be
worth looking at what was done there?

YMMV...

John
-- 
John W. Linville
linville@tuxdriver.com
