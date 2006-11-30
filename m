From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 12:55:06 -0800 (PST)
Message-ID: <20061130.125506.99459321.davem@davemloft.net>
References: <20061130203026.GD14696@elte.hu>
	<20061130.123853.10298783.davem@davemloft.net>
	<20061130204908.GA19393@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, nickpiggin@yahoo.com.au, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38634
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031446AbWK3UzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 15:55:05 -0500
To: mingo@elte.hu
In-Reply-To: <20061130204908.GA19393@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 30 Nov 2006 21:49:08 +0100

> So i dont support the scheme proposed here, the blatant bending of the 
> priority scale towards the TCP workload.

I don't support this scheme either ;-)

That's why my proposal is to find a way to allow input packet
processing even during tcp_recvmsg() work.  It is a solution that
would give the TCP task exactly it's time slice, no more, no less,
without the erroneous behavior of sleeping with packets held in the
socket backlog.
