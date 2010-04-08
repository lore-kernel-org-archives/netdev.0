From: David Miller <davem@davemloft.net>
Subject: Re: Patch to fix kernel bug 15678 - x25 code accesses fields
 beyond the end of packet.
Date: Wed, 07 Apr 2010 21:29:36 -0700 (PDT)
Message-ID: <20100407.212936.09766299.davem@davemloft.net>
References: <4BB8C0F1.2090100@Calva.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john@Calva.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751022Ab0DHE3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:29:33 -0400
In-Reply-To: <4BB8C0F1.2090100@Calva.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Hughes <john@Calva.COM>
Date: Sun, 04 Apr 2010 18:40:17 +0200

> From: John Hughes <john@calva.com>
> Subject: Patch to fix bug 15678 - x25 accesses fields beyond end of packet.
> 
> Here is a patch to stop X.25 examining fields beyond the end of the packet.
> 
> For example, when a simple CALL ACCEPTED was received:
> 
> 	10 10 0f
> 
> x25_parse_facilities was attempting to decode the FACILITIES field, but this
> packet contains no facilities field.
> 
> Signed-off-by: John Hughes <john@calva.com>

Applied, thanks John.
