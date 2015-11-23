From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac: debugfs broken with multiple ethernets.
Date: Mon, 23 Nov 2015 21:33:30 +0100
Message-ID: <20151123203329.GA30351@amd>
References: <20151123154917.GA17072@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34731 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbKWUdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:33:33 -0500
Content-Disposition: inline
In-Reply-To: <20151123154917.GA17072@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> stmmac_main will happily try to create two directories with the same
> name.
> 
> I guess something like
> 
> static int id;
> char name[100];
> 
> sprintf(name, STMMAC_RESOURCE_NAME "_%d", id++)
> ...
> 
> might be suitable, but did not try that further.

Hmm. It seems this is fixed in v4.1. Sorry for the noise.

Best regards,


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
