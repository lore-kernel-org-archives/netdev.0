From: David Miller <davem@davemloft.net>
Subject: Re: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
 retransmissions
Date: Tue, 14 Jul 2009 11:42:11 -0700 (PDT)
Message-ID: <20090714.114211.254914419.davem@davemloft.net>
References: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yinglin.s@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755520AbZGNSmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 14:42:07 -0400
In-Reply-To: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Sun <yinglin.s@gmail.com>
Date: Tue, 14 Jul 2009 14:38:07 -0400

> I have a question about tcp_ca_state "TCP_CA_CWR".  Under what
> circumstances does it enter this state?
> I'm doing some experiments and have trace from tcp_info. From tcp_info
> trace, I found that many places show ca_state is 2 (TCP_CA_CWR). Under
> this state, the congestion window size decreases but the total number
> of retransmissions is still 0.

What kind of "retransmissions"?  I bet the counter you are looking
at is counting timeout based retransmissions, which means it isn't
including the most predominant type of retransmissions, which are
fast retransmissions which are triggered in response to ACKs.
