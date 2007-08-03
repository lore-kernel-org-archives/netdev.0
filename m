From: David Miller <davem@davemloft.net>
Subject: Re: strange tcp behavior
Date: Fri, 03 Aug 2007 13:04:51 -0700 (PDT)
Message-ID: <20070803.130451.63127177.davem@davemloft.net>
References: <20070802184840.GA8901@2ka.mipt.ru>
	<20070802.192134.107254907.davem@davemloft.net>
	<20070803082242.GA25582@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760966AbXHCUQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 16:16:22 -0400
In-Reply-To: <20070803082242.GA25582@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 3 Aug 2007 12:22:42 +0400

> On Thu, Aug 02, 2007 at 07:21:34PM -0700, David Miller (davem@davemloft.net) wrote:
> > What in the world are we doing allowing stream sockets to autobind?
> > That is totally bogus.  Even if we autobind, that won't make a connect
> > happen.
> 
> For accepted socket it is perfectly valid assumption - we could autobind 
> it during the first send. Or may bind it during accept. Its a matter of
> taste I think. Autobinding during first sending can end up being a 
> protection against DoS in some obscure rare case...

accept()ed socket is by definition fully bound and already in
established state.
