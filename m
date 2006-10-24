From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Removing busy-spin in pktgen.
Date: Tue, 24 Oct 2006 03:14:55 -0700 (PDT)
Message-ID: <20061024.031455.55723788.davem@davemloft.net>
References: <453D582C.9020705@candelatech.com>
	<17725.55765.509953.762136@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38859
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965128AbWJXKOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 06:14:52 -0400
To: Robert.Olsson@data.slu.se
In-Reply-To: <17725.55765.509953.762136@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Tue, 24 Oct 2006 11:16:05 +0200

>  My first instinct is to avoid the hook in general code and pktgen let spin 
>  to only affect testing.

Mine too.

Why make everyone in the world make that check in netif_wake_queue(),
or wherever, when %99.99999999999 of the time it'll never be used?
