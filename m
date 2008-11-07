From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 14:29:50 +0000
Message-ID: <20081107142950.13906925@lxorguk.ukuu.org.uk>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
	<alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
	<20081105.151015.206163697.davem@davemloft.net>
	<alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
	<Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
	<4914240F.7050701@blueteddy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-14?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: Dave Hudson <linux-kernel@blueteddy.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4914240F.7050701@blueteddy.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Not all of the routers in question (the ones that crash, block packets 
> or otherwise misbehave) are provided by ISPs

The ones that block and misbehave are the bigger problem. The ones that
crash are less of a problem and I think they are less common. Certainly
if they were common then people would be abusing the flaw routinely.
Similar end users tend to grasp "if it keeps crashing blame the supplier".

When stuff just mysteriously doesn't work it is a whole lot more
problematic. I think however Sally Floyd had it right and Alexey has it
wrong (as does Davem).

If you turn it off on a retransmit then you provide an immediate
incentive for everyone on the web server end of the business to fix their
network. Especially if you turn it off for second retransmit. That will
cause faulty ECN handling sites to feel "a bit slow" and we know from
marketing data that web site performance is crucial to customer base. A
three or four second delay getting a page up translates into dramatically
reduced hit counts.

Alan
