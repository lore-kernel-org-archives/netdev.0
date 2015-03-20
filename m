From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 20 Mar 2015 23:04:54 +0100
Message-ID: <20150320220454.GA31769@lunn.ch>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
 <550C54BC.4040509@intel.com>
 <550C8B07.4010308@cumulusnetworks.com>
 <550C8FBD.2000903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us,
	ronen.arad@intel.com, netdev@vger.kernel.org,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53846 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbbCTWIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 18:08:36 -0400
Content-Disposition: inline
In-Reply-To: <550C8FBD.2000903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  In-kernel bridge driver is proven very useful for us to run stp,
> >or recently igmp reports (dont know the details here) etc in software.
> >I wonder how you handle these. If you don't use the in-kernel bridge
> >driver, I suspect you down the lane you will end-up having to duplicate a
> >lot of things that bridge driver already does in your switch driver.
> 
> I think that code is in need of some serious love before it is usable. I
> actually don't know who is using STP anymore if anyone.

We are using STP for the DSA switches. It is a good minimum to start
with, for these little switches with only a small number of ports, and
use in home WiFi routers etc.

    Andrew
