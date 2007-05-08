From: "Alexey Zaytsev" <alexey.zaytsev@gmail.com>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 8 May 2007 16:47:31 +0400
Message-ID: <f19298770705080547m3c0b5583qd6ad7aaca816361c@mail.gmail.com>
References: <m3abwhcy74.fsf@maximus.localdomain>
	 <m3vef5biob.fsf@maximus.localdomain>
	 <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	 <m3hcqoa772.fsf@maximus.localdomain>
	 <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	 <m33b289zku.fsf@maximus.localdomain>
	 <m31whs5ehn.fsf_-_@maximus.localdomain>
	 <20070508113232.GA32055@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Halasa" <khc@pm.waw.pl>,
	"Michael-Luke Jones" <mlj28@cam.ac.uk>,
	"Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	"Russell King" <rmk@arm.linux.org.uk>,
	"ARM Linux Mailing List" <linux-arm-kernel@lists.arm.linux.org.uk>
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:9764 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966124AbXEHMrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 08:47:33 -0400
Received: by ik-out-1112.google.com with SMTP id b35so1528954ika
        for <netdev@vger.kernel.org>; Tue, 08 May 2007 05:47:31 -0700 (PDT)
In-Reply-To: <20070508113232.GA32055@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/8/07, Lennert Buytenhek <buytenh@wantstofly.org> wrote:
...
> As with Christian's driver, I don't know whether an SRAM allocator
> makes much sense.  We can just set up a static allocation map for the
> in-tree drivers and leave out the allocator altogether.  I.e. I don't
> think it's worth the complexity (and just because the butt-ugly Intel
> code has an allocator isn't a very good reason. :-)

Is the qmgr used when the NPEs are utilized as DMA engines? And is the
allocator needed in this case? If yes, I beg you not to drop it,
because we use one NPE for this purpose, and if we are going to adopt
this driver instead of the intel's one, you will receive a patch
adding DMA functionality very soon. ;)
