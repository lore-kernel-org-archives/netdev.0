From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 1/7] ipaddress: Make buffer for filter.flushb
 static
Date: Fri, 18 Aug 2017 13:57:03 +0200
Message-ID: <20170818115703.GC16375@orbyte.nwl.cc>
References: <20170817170931.24302-1-phil@nwl.cc>
 <20170817170931.24302-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60367 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdHRL5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 07:57:04 -0400
Content-Disposition: inline
In-Reply-To: <20170817170931.24302-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 07:09:25PM +0200, Phil Sutter wrote:
> The buffer is accessed outside of the function defining it, so make it
> static.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Self-NACK: Access to flushb should be sane since all accessors are
called from ipaddr_flush(). Looking at the covscan output again, it
merely complained about filter.flusb still pointing to the local buffer
when ipaddr_flush() returns.

Cheers, Phil
