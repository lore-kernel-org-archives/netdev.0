From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5 net-next-2.6] [TIPC]: Consolidate subscriber &
 subscriber port references
Date: Mon, 19 May 2008 13:30:40 -0700 (PDT)
Message-ID: <20080519.133040.120076575.davem@davemloft.net>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
	<1210702665-5012-5-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754823AbYESUap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:30:45 -0400
In-Reply-To: <1210702665-5012-5-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 13 May 2008 14:17:44 -0400

> This patch modifies TIPC's network topology service so that it
> only requires a single reference table entry per subscriber
> connection, rather than two.  This is achieved by letting the
> reference to the server port communicating with the subscriber
> act as the reference to the subscriber object itself.  (Since
> the subscriber cannot exist without its port, and vice versa,
> this dual role for the reference is perfectly natural.)  This
> consolidation reduces the size of the reference table by 50%
> in the default configuration.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
