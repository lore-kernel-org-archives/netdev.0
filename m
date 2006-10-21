From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'we21-fix' branch of wireless-2.6.git
Date: Sat, 21 Oct 2006 14:12:34 -0400
Message-ID: <453A6312.3030207@garzik.org>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com> <20061010193959.GC5728@tuxdriver.com> <20061010202803.GA17177@bougret.hpl.hp.com> <20061019215647.GA18217@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63723 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964773AbWJUSMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 14:12:52 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061019215647.GA18217@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff,
> 
> Here is my ugly patch to fix userland ABI compatibility for WE-21.
> It tries to detect WE <= 20 by the request length or the inclusion of
> '\0' in the length for the ESSID and NICKN ioctls.  If it finds that,
> it temporarily adjusts the length value and puts it back before
> reporting back to userland.
> 
> It is possible that there are more elegant solutions that work, but
> I'm not totally convinced that they truly preserve the ABI as desired.
> Please see the discussion earlier in this thread if you are interested.
> 
> I'm aware that checking for '\0' is problematic, since that technically
> is a valid SSID character even at the end of the SSID.  I'm afraid
> we will just have to live with that limitation.
> 
> I have the single patch on its own "clean" branch from Linus's tree of
> a few days ago.  That way you can pull just this fix without concern
> about picking-up the other fixes which I posted a few days ago,
> in case you haven't reviewed them yet.
> 
> Obviously, this is intended for 2.6.19.
> 
> Thanks,
> 
> John
> ---
> 
> The following changes since commit 51018b0a3160d253283173c2f54f16746cee5852:
>   Ulrich Drepper:
>         make UML compile (FC6/x86-64)
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/wireless-2.6.git we21-fix

pulled, after adding "git/linville/" to the URL...

	Jeff



