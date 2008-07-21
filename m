From: David Miller <davem@davemloft.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 13:15:59 -0700 (PDT)
Message-ID: <20080721.131559.258601277.davem@davemloft.net>
References: <20080721193425.GA29287@elte.hu>
	<4884E6E6.7010800@lwfinger.net>
	<alpine.LFD.1.10.0807211246280.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, mingo@elte.hu, ischram@telenet.be,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	j@w1.fi
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbYGUUQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:16:00 -0400
In-Reply-To: <alpine.LFD.1.10.0807211246280.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 Jul 2008 12:47:58 -0700 (PDT)

> On Mon, 21 Jul 2008, Larry Finger wrote:
> > With an invalid opcode, mine is likely due to stack corruption.
> 
> No, invalid opcode is because we use the "ud2" instruction for BUG(), 
> which causes an invalid op exception. So any BUG[_ON]() will always cause 
> that on x86.

Is there really no more backtrace from that crash message?
It would tell me what driver it's in.

There is some "comm: b43" in the log so I'll check that one.
