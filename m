From: David Miller <davem@davemloft.net>
Subject: Re: xfrm: avoid spinlock in get_acqseq() used by xfrm user
Date: Tue, 16 Feb 2010 20:20:50 -0800 (PST)
Message-ID: <20100216.202050.226776926.davem@davemloft.net>
References: <1266321682.6776.254.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43094
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934011Ab0BQEUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 23:20:34 -0500
In-Reply-To: <1266321682.6776.254.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 16 Feb 2010 07:01:22 -0500

> Eric's version fixed it for pfkey. This one is for xfrm user.
> I thought about amortizing those two get_acqseq()s but it seems
> reasonable to have two of these sequence spaces for the two different
> interfaces.

Applied, thanks Jamal.
