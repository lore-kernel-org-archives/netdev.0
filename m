From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] RF Kill
Date: Thu, 26 Apr 2007 01:00:29 -0700
Message-ID: <20070426010029.0bd49f3b.akpm@linux-foundation.org>
References: <200704100158.58451.dtor@insightbb.com>
	<200704100229.32393.dtor@insightbb.com>
	<20070426.004951.85412315.davem@davemloft.net>
	<20070426.005457.27951605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dtor@insightbb.com, netdev@vger.kernel.org, ivdoorn@gmail.com,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:50568 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933632AbXDZIBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:01:42 -0400
In-Reply-To: <20070426.005457.27951605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Apr 2007 00:54:57 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Thu, 26 Apr 2007 00:49:51 -0700 (PDT)
> 
> > From: Dmitry Torokhov <dtor@insightbb.com>
> > Date: Tue, 10 Apr 2007 02:29:31 -0400
> > 
> > > On Tuesday 10 April 2007 01:58, Dmitry Torokhov wrote:
> > > > Hi,
> > > > 
> > > > This is a modified version of rfkill patch that provides infrastructure
> > > > for controlling state of RF transmitters found on various cards.
> > > 
> > > Well, Andrew found bunch of issues with the patch so here is an
> > > updated version...
> > 
> > Patch applied, although one part of the locking is slightly
> > suspect:
> 
> Actually, I'm reverting this, sorry.
> 
> Besides the locking and other issues I pointed out, this
> thing won't even link.  Please do not test the build with
> various configurations when submitting new code like this.
> 
> Thanks.
> 
>   MODPOST 139 modules
> WARNING: "input_register_handle" [net/rfkill/rfkill-input.ko] undefined!
> WARNING: "input_unregister_handle" [net/rfkill/rfkill-input.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2

ah, OK, it has input dependencies, sorry.  It happens very rarely.

