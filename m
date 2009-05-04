From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying
 toifenslave a second interface to my bond
Date: Tue, 05 May 2009 00:05:12 +0100
Message-ID: <1241478312.23179.5.camel@deadeye>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	 <1241397581.6499.658.camel@homebase.localnet>
	 <4086.1241463817@death.nxdomain.ibm.com>
	 <20090504.120651.32573620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, paul@mad-scientist.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57272 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753240AbZEDXF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 19:05:27 -0400
In-Reply-To: <20090504.120651.32573620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-04 at 12:06 -0700, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Mon, 04 May 2009 12:03:37 -0700
> 
> > Paul Smith <paul@mad-scientist.net> wrote:
> > 
> >>Hi Jay/David/etc.;
> >>
> >>This patch is critical for me to properly use mode 6 (balance-alb)
> >>bonding; I assume it will be needed for others as well.  I haven't
> >>checked to see if it's still necessary in 2.6.29/2.6.30, but I didn't
> >>notice it going into the latest 2.6.27.22, released today.
> >>
> >>Is this still unofficial?  Is there an official patch on the horizon?
> > 
> > 	David, please apply and queue for -stable:
> 
> Greg just posted that there will be no further 2.6.27.x -stable
> releases after the one he just made.

It's 2.6.28.x that he's dropping now
<http://article.gmane.org/gmane.linux.kernel/831202>, not .27.x - he'll
have to support the latter for years in SLES 11 anyway.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
