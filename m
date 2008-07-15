From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 17:43:21 -0700
Message-ID: <20080714174321.30d6d62a@extreme>
References: <200807141843.00845.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.93.170.194] ([216.93.170.194]:37633 "EHLO mail.vyatta.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754410AbYGOAna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 20:43:30 -0400
In-Reply-To: <200807141843.00845.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jul 2008 18:43:00 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> Hi everybody,
> 
> In our Linux port we added a new sk_buff member, hwstamp, to store a hardware 
> generated timestamp for received packets. The hardware can also insert  
> hardware timestamps in the payload on the TX path and can have the RX / TX 
> clocks synchronized. We use this infrastructure to compute one-way delays 
> with high precision (20ns resolution).
> 
> I know that adding new members to such heavily used structures like the skb is 
> viewed harshly - especially for such exotic cases as the one described above. 
> So, would such a patch be considered for inclusion? Or maybe there is a 
> better way of doing the above?
> 

Why not do some clock synchronization and use existing absolute timestamp?
This would benefit system generally since it would give more accurate values
for network traffic analysis.
