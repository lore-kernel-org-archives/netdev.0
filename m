From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 7 Oct 2014 13:33:44 -0700
Message-ID: <20141007203344.GA4748@roeck-us.net>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be>
 <20141007.161832.453892039501955243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:47390 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbaJGUdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:33:54 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XbbSE-0049UZ-Es
	for netdev@vger.kernel.org; Tue, 07 Oct 2014 20:33:54 +0000
Content-Disposition: inline
In-Reply-To: <20141007.161832.453892039501955243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2014 at 04:18:32PM -0400, David Miller wrote:
> From: Fabian Frederick <fabf@skynet.be>
> Date: Tue,  7 Oct 2014 22:16:36 +0200
> 
> > static values are automatically initialized to NULL
> > 
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> 
> Isn't there some implementation room given to compilers
> as to the representation of true and false?

Not for true/false.

C99 standard, section 7.16:

...
The remaining three macros are suitable for use in #if preprocessing
directives. They are

true

which expands to the integer constant 1,

false

which expands to the integer constant 0, and
...

No idea where the NULL comes into the picture, though.

Guenter
