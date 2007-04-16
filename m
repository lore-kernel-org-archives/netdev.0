From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] [0/4] pasemi_mac: fixes and enhancements
Date: Mon, 16 Apr 2007 02:05:19 -0500
Message-ID: <20070416070519.GA20688@lixom.net>
References: <20070416061654.GB19783@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:52972 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932315AbXDPGrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 02:47:16 -0400
Content-Disposition: inline
In-Reply-To: <20070416061654.GB19783@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2007 at 01:16:54AM -0500, Olof Johansson wrote:
> Hi,
> 
> The four following patches contain a number of fixes and improvements
> of the pasemi_mac driver:

I just realized that these have been based on top of some OF API changes
that are in paulus' for-2.6.22 tree, and won't build on something based
on current mainline.

I'll fix this up when I respin based on first round of comments in the
next day or so. It should mostly be a matter of doing rename of_$foo()
-> $foo().


-Olof
