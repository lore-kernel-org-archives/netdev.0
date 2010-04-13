From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 3/9] net: fib_rules: decouple address families from
 real address families
Date: Tue, 13 Apr 2010 04:08:36 -0700 (PDT)
Message-ID: <20100413.040836.172611633.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-4-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753196Ab0DMLIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:08:32 -0400
In-Reply-To: <1271007435-20035-4-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:09 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> Decouple the address family values used for fib_rules from the real
> address families in socket.h. This allows to use fib_rules for
> code that is not a real address family without increasing AF_MAX/NPROTO.
> 
> Values up to 127 are reserved for real address families and map directly
> to the corresponding AF value, values starting from 128 are for other
> uses. rtnetlink is changed to invoke the AF_UNSPEC dumpit/doit handlers
> for these families.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Ok.
