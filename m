From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Please pull 'we21-fix' branch of wireless-2.6.git
Date: Thu, 19 Oct 2006 15:10:59 -0700
Message-ID: <20061019221059.GC9966@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com> <20061010193959.GC5728@tuxdriver.com> <20061010202803.GA17177@bougret.hpl.hp.com> <20061019215647.GA18217@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Jouni Malinen <jkm@devicescape.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:64740 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1946570AbWJSWNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 18:13:41 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20061019215647.GA18217@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2006 at 05:56:53PM -0400, John W. Linville wrote:
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

	I agree that this is a good compromise.
	Thanks a lot for your work, John !

	Jean
