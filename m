From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 1/7] ipaddress: Make buffer for filter.flushb
 static
Date: Fri, 18 Aug 2017 08:55:19 -0700
Message-ID: <20170818085519.5a81f54f@xeon-e3>
References: <20170817170931.24302-1-phil@nwl.cc>
        <20170817170931.24302-2-phil@nwl.cc>
        <20170818115703.GC16375@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:37577 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdHRPz1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 11:55:27 -0400
Received: by mail-pg0-f51.google.com with SMTP id y129so66890252pgy.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 08:55:27 -0700 (PDT)
In-Reply-To: <20170818115703.GC16375@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Aug 2017 13:57:03 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Thu, Aug 17, 2017 at 07:09:25PM +0200, Phil Sutter wrote:
> > The buffer is accessed outside of the function defining it, so make it
> > static.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>  
> 
> Self-NACK: Access to flushb should be sane since all accessors are
> called from ipaddr_flush(). Looking at the covscan output again, it
> merely complained about filter.flusb still pointing to the local buffer
> when ipaddr_flush() returns.
> 
> Cheers, Phil

Ok, dropping this  sub-series
