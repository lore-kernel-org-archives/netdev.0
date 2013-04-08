From: David Miller <davem@davemloft.net>
Subject: Re: unix STREAM/SEQPACKET sockets and SO_PASSCRED race
Date: Mon, 08 Apr 2013 17:02:52 -0400 (EDT)
Message-ID: <20130408.170252.618527000564326903.davem@davemloft.net>
References: <CAPXgP106kvseQ_0ATmY38vPk1Sw+Y6+GBosJUcJ2YjfZKrHfzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kay@vrfy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935536Ab3DHVCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 17:02:53 -0400
In-Reply-To: <CAPXgP106kvseQ_0ATmY38vPk1Sw+Y6+GBosJUcJ2YjfZKrHfzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kay Sievers <kay@vrfy.org>
Date: Mon, 8 Apr 2013 22:55:28 +0200

> If not, could we inherit/copy over the PASSCRED bit from the listen
> socket to the connection socket. Servers could set the flag there to
> receive it for the accepted connections?

We could start doing that yes, this is similar to what we did for
things like non-nonblocking flags on TCP sockets a long time ago.
