From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 11:26:22 -0700 (PDT)
Message-ID: <20081007.112622.73930718.davem@davemloft.net>
References: <48EA8197.6080502@cosmosbay.com>
	<20081006.144002.56418911.davem@davemloft.net>
	<48EAF29D.8050203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: dada1@cosmosbay.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755473AbYJGS1A@vger.kernel.org>
In-Reply-To: <48EAF29D.8050203@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 07 Oct 2008 07:24:45 +0200

> Most UDP sockets are setup for long periods (RTP trafic), or if an application really
> wants to {open/send or receive one UDP frame/close} many sockets, it already hits
> RCU handling of its file structures and should not be slowed down that much.

As stated, I added RCU destruction generically for socket objects, and it
showed up clearly.

So "not be slowed down that much" has been disproven, at least to me,
already :-)
