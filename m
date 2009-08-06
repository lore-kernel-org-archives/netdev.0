From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Add a mutex around ethtools operations
Date: Wed, 5 Aug 2009 17:41:58 -0700
Message-ID: <20090805174158.383dcc03@nehalam>
References: <4A7A0BAA.7020104@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55280 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724AbZHFAnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 20:43:25 -0400
In-Reply-To: <4A7A0BAA.7020104@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Aug 2009 07:46:02 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> As multiple sky2 devices share some of the same hardware, and ethtool
> operations are per device, access to transmit timers, eeprom access,
>  coalesce, etc. should be serialized.
> 
> Only tested on a single port card, as my sky2 doesn't have dual ports.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

NAK.
The ethtool operations are already serialized by rtnl mutex at
higher level.  See net/core/dev.c 
