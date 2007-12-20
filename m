From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25][NEIGH] Make neigh_add_timer symmetrical to
 neigh_del_timer
Date: Thu, 20 Dec 2007 15:50:11 -0800 (PST)
Message-ID: <20071220.155011.245874156.davem@davemloft.net>
References: <476A3AED.7080503@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754944AbXLTXuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:50:12 -0500
In-Reply-To: <476A3AED.7080503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 20 Dec 2007 12:50:37 +0300

> The neigh_del_timer() looks sane - it removes the timer and
> (conditionally) puts the neighbor. I expected, that the
> neigh_add_timer() is symmetrical to the del one - i.e. it
> holds the neighbor and arms the timer - but it turned out
> that it was not so.
> 
> I think, that making them look symmetrical makes the code 
> more readable.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I agree, it looks more reable now, applied.

This code used to be a lot worse, I think we had some
confusion about whether the timer should always not be
pending in these circumstances.  But that was a bug
fix from a long time ago, however I believe that's
where the dump_stack() bug check came from in the
add timer case.
