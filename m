From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 20 Mar 2015 23:09:46 +0100
Message-ID: <20150320220946.GB31769@lunn.ch>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
 <20150320.163655.474336751434677390.davem@davemloft.net>
 <550C92F3.50302@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53856 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbbCTWNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 18:13:24 -0400
Content-Disposition: inline
In-Reply-To: <550C92F3.50302@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> since we have discussed this problem multiple times in switchdev meetings,
> the intent of this RFC is to see get the code out and also see if
> rocker or any other in-kernel
> driver can use it.

The Marvell switches in DSA don't have any way to mark packets why
they where forwarded towards the host. So i don't see how we could use
this feature with these chips.

     Andrew
