From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] deprecate print_mac
Date: Mon, 27 Oct 2008 15:49:39 -0700 (PDT)
Message-ID: <20081027.154939.236533658.davem@davemloft.net>
References: <1224893395.3919.39.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751284AbYJ0WuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:50:03 -0400
In-Reply-To: <1224893395.3919.39.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 25 Oct 2008 02:09:55 +0200

> Or more precisely, deprecate the variables that DECLARE_MAC_BUF
> creates, DECLARE_MAC_BUF is required for print_mac and the latter
> uses the created variables.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> I don't think we want this without the bulk of the users removed. And
> after that, it should be removed before long anyway.

I've decided not to apply this one.  Anyone who wants to help get rid
of this can run grep, otherwise it's just compile noise that doesn't
really help but does annoy. :-)

