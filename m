From: David Miller <davem@davemloft.net>
Subject: Re: patch to improve x.25 throughput negotiation
Date: Wed, 07 Apr 2010 21:33:14 -0700 (PDT)
Message-ID: <20100407.213314.156725109.davem@davemloft.net>
References: <4BB8C2CA.6040102@Calva.COM>
	<v2jd45a3acc1004060509u88f32fa1va0c374154806535b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@calva.com, netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38438
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab0DHEdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:33:12 -0400
In-Reply-To: <v2jd45a3acc1004060509u88f32fa1va0c374154806535b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: andrew hendry <andrew.hendry@gmail.com>
Date: Tue, 6 Apr 2010 22:09:10 +1000

> I have reproduced a few ways.
> 1. X25_MASK_THROUGHPUT on the x25_subscript_struct, then call
> SIOCX25SSUBSCRIP, then call SIOCX25FACILITIES without setting the
> throughput field. Call connect.
> 2. No subscrip setting, call SIOCX25FACILITIES without setting the
> throughput field. Call connect.
> 3. No subcrip, no facilities ioctl, call connect.
> 
> The patch removes the bad facility and makes the router accept the
> call for the above cases.
> I don't currently have a setup to test both direction throughput negotiation.
> 
> Tested-by: Andrew Hendry <andrew.hendry@gmail.com>

Patch applied, thanks everyone.
