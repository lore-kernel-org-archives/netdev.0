From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Tue, 16 Dec 2008 15:55:40 -0800 (PST)
Message-ID: <20081216.155540.34452478.davem@davemloft.net>
References: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com>
	<20081211160307.20709435@s6510>
	<20081212121835.GA2402@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbYLPXzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:55:38 -0500
In-Reply-To: <20081212121835.GA2402@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 12 Dec 2008 07:18:35 -0500

> On Thu, Dec 11, 2008 at 04:03:07PM -0800, Stephen Hemminger wrote:
> > I would ask it the other way. Why is interface an argument to netif_rx_complete
> > if it is never used?  
> > 
> Thats a fair question, and I don't know the answer, Dave?

That's just what the old code uses, since the NAPI context
sat inside of the device.  I just never removed it.
