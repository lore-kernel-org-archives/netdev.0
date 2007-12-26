From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipv4: Update ip command line processing (take II)
Date: Wed, 26 Dec 2007 14:04:37 +0900
Message-ID: <20071226050435.GA18934@verge.net.au>
References: <20071226025903.GB14422@verge.net.au> <20071225.205543.240106823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:57031 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbXLZFEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 00:04:41 -0500
Content-Disposition: inline
In-Reply-To: <20071225.205543.240106823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 25, 2007 at 08:55:43PM -0800, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Wed, 26 Dec 2007 11:59:05 +0900
> 
> > Recently the documentation in Documentation/nfsroot.txt was
> > update to note that in fact ip=off and ip=::::::off as the
> > latter is ignored and the default (on) is used.
> > 
> > This was certainly a step in the direction of reducing confusion.
> > But it seems to me that the code ought to be fixed up so that
> > ip=::::::off actually turns off ip autoconfiguration.
> > 
> > This patch also notes more specifically that ip=on (aka ip=::::::on)
> > is the default.
> > 
> > Cc: Amos Waterland <apw@us.ibm.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> I applied this to net-2.6 since I think it's a bug fix, and
> I also tailored the changelog header to more it clear this
> is a fix not just an "Update". :-)

Ok, thanks.

-- 
Horms

