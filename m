From: Pavel Machek <pavel@denx.de>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 4 Dec 2015 10:38:38 +0100
Message-ID: <20151204093837.GB22014@amd>
References: <561FF9E2.30102@opensource.altera.com>
 <56200687.9040903@gmail.com>
 <562005AD.8020903@opensource.altera.com>
 <56200BD7.8020505@gmail.com>
 <20151203204811.GB14427@amd>
 <5660B2EC.1050705@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5660B2EC.1050705@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> >While updating DTS might be good idea, I don't think you can simply
> >blame this on DTS. If it worked before the change, it is supposed to
> >work after the change, otherwise we call that change a "regression"
> >and revert the change.
> 
> FWIW: My initial patch to address the failure worked with the original DTB.
> 
> Also: userspace wasn't broken. So, the commandment about not breaking
> userspace wasn't broken.  Although admittedly, breaking the kernel isn't
> good either.

You can't break neither kernel nor userspace.

> >Plus, DTS is supposed to be ABI. Old DTS should still work on new
> >kernels in ideal world.
> 
> If you supply the device tree file in the kernel tree, it is not an ABI.
> 
> If the device tree is not part of the kernel, and instead comes from the
> boot firmware of the board, then you could make the ABI claim.

It is an ABI if it was declared so, and it was. Yes, it _can_ come
from kernel tree. That does not mean it has to.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
