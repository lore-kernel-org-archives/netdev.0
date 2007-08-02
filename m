From: David Miller <davem@davemloft.net>
Subject: Re: strange tcp behavior
Date: Thu, 02 Aug 2007 15:02:36 -0700 (PDT)
Message-ID: <20070802.150236.27783571.davem@davemloft.net>
References: <46B21148.2090004@simon.arlott.org.uk>
	<20070802180842.GA6864@2ka.mipt.ru>
	<20070802184840.GA8901@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754294AbXHBWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 18:02:36 -0400
In-Reply-To: <20070802184840.GA8901@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 2 Aug 2007 22:48:42 +0400

> On Thu, Aug 02, 2007 at 10:08:42PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > So, following patch fixes problem for me.
> 
> Or this one. Essentially the same though.

Thanks a lot for figuring out this bug Evgeniy, I'll look at
this later.  I'm very surprised autobind isn't guarded properly
as this is a case that Alexey Kuznetsov and I used to audit from
time to time.
