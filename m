From: Borislav Petkov <bp@alien8.de>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 12:42:13 +0100
Message-ID: <20121223114213.GB8386@liondog.tnic>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:54496 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab2LWLmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2012 06:42:16 -0500
Content-Disposition: inline
In-Reply-To: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2012 at 04:14:39AM +0100, Sedat Dilek wrote:
> Hi,
> 
> after reading the thread "Regression in 3.8-rc1: "BUG: sleeping
> function called from invalid context"" [1] I decided to pull-in
> net.git#master (up to commit 9b1536c490d5: "bridge: call
> br_netpoll_disable in br_add_if") on top of Linus upstream.
> 
> With this kernel I can't neither ping my router nor does DNS work.
> IIRC there were 6 commits, not sure which of them is culprit.
> 
> I tried the v3.8-rc1-raring from [2] which works nicely here on
> Ubuntu/precise AMD64.
> Can't say if NetworkManager is involved or not.

Does that mean that with Linus upstream, i.e. 3.8-rc1, you can ping your
router, etc?

If so, you could bisect the 6 commits...

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
