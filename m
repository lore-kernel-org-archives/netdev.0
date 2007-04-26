From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] RF Kill
Date: Thu, 26 Apr 2007 00:54:57 -0700 (PDT)
Message-ID: <20070426.005457.27951605.davem@davemloft.net>
References: <200704100158.58451.dtor@insightbb.com>
	<200704100229.32393.dtor@insightbb.com>
	<20070426.004951.85412315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivdoorn@gmail.com, linville@tuxdriver.com,
	akpm@linux-foundation.org
To: dtor@insightbb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933473AbXDZHyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:54:49 -0400
In-Reply-To: <20070426.004951.85412315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 00:49:51 -0700 (PDT)

> From: Dmitry Torokhov <dtor@insightbb.com>
> Date: Tue, 10 Apr 2007 02:29:31 -0400
> 
> > On Tuesday 10 April 2007 01:58, Dmitry Torokhov wrote:
> > > Hi,
> > > 
> > > This is a modified version of rfkill patch that provides infrastructure
> > > for controlling state of RF transmitters found on various cards.
> > 
> > Well, Andrew found bunch of issues with the patch so here is an
> > updated version...
> 
> Patch applied, although one part of the locking is slightly
> suspect:

Actually, I'm reverting this, sorry.

Besides the locking and other issues I pointed out, this
thing won't even link.  Please do not test the build with
various configurations when submitting new code like this.

Thanks.

  MODPOST 139 modules
WARNING: "input_register_handle" [net/rfkill/rfkill-input.ko] undefined!
WARNING: "input_unregister_handle" [net/rfkill/rfkill-input.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2
