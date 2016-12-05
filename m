From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management
 frames to CPU
Date: Mon, 5 Dec 2016 09:26:07 +0100
Message-ID: <20161205082607.GA18980@localhost.localdomain>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
 <1480736720-12608-2-git-send-email-andrew@lunn.ch>
 <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
 <20161204202234.GA20743@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33385 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbcLEI0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 03:26:12 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so14259401wmu.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 00:26:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161204202234.GA20743@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 09:22:34PM +0100, Andrew Lunn wrote:
> 3) We have a prefix for us humans to help us find the code. Now we
> have ops, i cannot simply do M-. and emacs will take me to the
> implementation. I have to search for it a bit. Having the hint g1_
> tells me to go look in global1.c. Having the hint g2_ tells me to go
> look in global2.c. Having the port_ tells me to go look in port.c.
> Having no prefix tells me the code is scattered around and grep is my
> friend.
> 
> The prefix is just a hint where the function is in the source
> code. Nothing more.

Just chiming in here:  Having a function interface with callback
functions is widely used pattern in the kernel, but adding little
prefixes is not.  Sure, you have to look to find a particular instance
of a callback, but it isn't _that_ hard.

Thanks,
Richard
