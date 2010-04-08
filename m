From: David Miller <davem@davemloft.net>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 04:01:41 -0700 (PDT)
Message-ID: <20100408.040141.66855166.davem@davemloft.net>
References: <20100408.035049.177640912.davem@davemloft.net>
	<20100408105951.GA16868@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758525Ab0DHLBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:01:38 -0400
In-Reply-To: <20100408105951.GA16868@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 8 Apr 2010 06:59:51 -0400

> Dave, sorry to be late to the discussion, but can you refesh us on
> why dhcp has to sniff every packet?

It wants to see DHCP packets from the server.

And it can't use ipv4 RAW sockets due to some limitations wrt. getting
at the link layer headers when using that interfaces.
