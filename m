From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 01:35:56 -0700 (PDT)
Message-ID: <20091013.013556.57098460.davem@davemloft.net>
References: <4AD42B0F.8010809@gmail.com>
	<20091013073410.GA3792@1wt.eu>
	<4AD43A4F.1090800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758212AbZJMIgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 04:36:00 -0400
In-Reply-To: <4AD43A4F.1090800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Oct 2009 10:29:03 +0200

> Indeed, thanks for this detailed explanation, I missed the SYN-ACK timer
> and retransmits.
> 
> I played some years ago with TCP_DEFER_ACCEPT and got some unexpected results
> on transmitted packets (server was consuming more bandwidth), and I know understand
> it was very broken until today !
> 
> Thanks again Willy

Ok, and with that I put Willy's patch back in.

Thanks!
