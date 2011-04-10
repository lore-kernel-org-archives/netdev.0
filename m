From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Sun, 10 Apr 2011 13:58:05 -0700 (PDT)
Message-ID: <20110410.135805.71122561.davem@davemloft.net>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
	<20110410135007.7a4eccdf@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754441Ab1DJU6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 16:58:41 -0400
In-Reply-To: <20110410135007.7a4eccdf@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sun, 10 Apr 2011 13:50:07 -0700

> You lost GRO flag in the conversion. Since code calls gro_receive,
> this is necessary.

I think the way it works now is that the generic core turns on
GRO all the time, and this way driver's don't need to be concerned
about it.
