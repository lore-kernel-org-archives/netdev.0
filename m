From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ppp: Bridge Control Protocol
Date: Mon, 1 Mar 2010 20:40:57 -0800
Message-ID: <20100301204057.11a7c353@s6510>
References: <20100301145915.2ecaac89@nehalam>
	<20100302033944.GL26848@brick.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David@mail.vyatta.com, "Miller <davem"@davemloft.net,
	linux-ppp@vger.kernel.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org, dane@aiinet.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60817 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753250Ab0CBElM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 23:41:12 -0500
In-Reply-To: <20100302033944.GL26848@brick.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Mar 2010 14:39:44 +1100
Paul Mackerras <paulus@samba.org> wrote:

> On Mon, Mar 01, 2010 at 02:59:15PM -0800, Stephen Hemminger wrote:
> 
> > This is a port of an old patch to provide BCP support.
> > BCP allows bridging PPP tunnels, it useful to do bridging between
> > virtualized environments. Original patch was done by
> > Dan Eble but was for 2.4.21.
> > 
> > Note: still needs testing. Does anyone have hardware to make
> > sure this interoperates with other implementations?
> 
> Is there a corresponding pppd patch to handle the control protocol?
> 
> Paul.

Yes, I am working on that
