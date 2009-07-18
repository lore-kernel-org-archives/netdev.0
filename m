From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Fri, 17 Jul 2009 20:54:00 -0700 (PDT)
Message-ID: <20090717.205400.202210753.davem@davemloft.net>
References: <65634d660907171105s4989758ah533203d107924b6a@mail.gmail.com>
	<20090717.110840.128146209.davem@davemloft.net>
	<65634d660907171259l2a3a31fel549176274201bd66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49852
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757732AbZGRDxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 23:53:55 -0400
In-Reply-To: <65634d660907171259l2a3a31fel549176274201bd66@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 17 Jul 2009 12:59:31 -0700

> eth_type_trans does not need to even be called assuming that the
> packet type information can be inferred from the RX descriptor.

Great assumption :-)

We investigated doing that in the past but it's racey and can't be
made to work in all situations.
