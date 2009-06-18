From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: kernel dies if loopback device not intialized
Date: Thu, 18 Jun 2009 07:25:12 -0500
Message-ID: <1245327912.7609.1.camel@Maple>
References: <20090610203536.4357d309@nehalam>
	 <1245080498.7134.15.camel@Maple>  <20090616215331.2a1bd276@nehalam>
	 <1245293482.10073.5.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:17596 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbZFRMZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:25:13 -0400
Received: by yw-out-2324.google.com with SMTP id 5so554642ywb.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 05:25:15 -0700 (PDT)
In-Reply-To: <1245293482.10073.5.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-17 at 21:51 -0500, John Dykstra wrote:
> > The packets come from SNMP smux which opens a TCP socket over 127.1
> > but the loopback interface is in admin down. 
> 
> Hmmm...the stack is doing the ARP because it doesn't have a valid route
> for 127.0.0.1.  But I would expect it to be ARPing a default router, and
> getting a response (modulo your network state).  What am I missing?

Never mind.  This box is a router, with no default routes.

  --  John

