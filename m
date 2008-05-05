From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9 net-next-2.6] [TIPC]: Elimination of print buffer
 chaining
Date: Mon, 05 May 2008 01:22:39 -0700 (PDT)
Message-ID: <20080505.012239.141971400.davem@davemloft.net>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
	<1209412126-2109-6-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753331AbYEEIWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:22:39 -0400
In-Reply-To: <1209412126-2109-6-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 28 Apr 2008 15:48:42 -0400

> This patch revamps TIPC's print buffer subsystem to eliminate
> support for arbitrary chains of print buffers, which were
> rarely needed and difficult to use safely.
> 
> In its place, print buffers can now be configured to echo their
> output to the system console.  This provides an equivalent for
> the only chaining currently utilized by TIPC, in a faster and
> more compact manner.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
