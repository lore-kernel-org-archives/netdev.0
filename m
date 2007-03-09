From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19/2.6.20 BUG in inet_rtm_newaddr()/__inet_insert_ifa()
Date: Fri, 09 Mar 2007 13:43:58 -0800 (PST)
Message-ID: <20070309.134358.52132045.davem@davemloft.net>
References: <20070309103333.GA17232@janus>
	<20070309123016.GA4736@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: frankvm@frankvm.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752760AbXCIVn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 16:43:59 -0500
In-Reply-To: <20070309123016.GA4736@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 9 Mar 2007 15:30:17 +0300

> On Fri, Mar 09, 2007 at 11:33:33AM +0100, Frank van Maarseveen (frankvm@frankvm.com) wrote:
> > Try this:
> > 
> > ip addr add 172.18.12.99/21 dev dummy0
> > ip addr add broadcast 172.18.15.255 dev dummy0
> 
> Attached patch fixes the problem.
> 
> nlmsg_parse() in rtm_to_ifaddr() sucessfully returns zero, but
> subsequent check for prefix len and LOCAL ifa fails, so NULL is returned
> instead of negative error value embedded in the pointer which is
> expected by error logic in inet_rtm_newaddr().

Patch applied, thanks Evgeniy.
