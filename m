From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 v2] sunrpc: Remove sk_no_check setting
Date: Wed, 21 May 2014 16:37:35 -0400 (EDT)
Message-ID: <20140521.163735.1815284886558779067.davem@davemloft.net>
References: <alpine.DEB.2.02.1405120946520.551@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbaEUUhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 16:37:37 -0400
In-Reply-To: <alpine.DEB.2.02.1405120946520.551@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 19 May 2014 10:09:56 -0700 (PDT)

> Setting sk_no_check to UDP_CSUM_NORCV seems to have no effect.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

It does have an effect.

All of the UDP receive paths check for sk->sk_no_check being non-zero,
causing it to accept packets with a zero checksum.

You're changing behavior here.
