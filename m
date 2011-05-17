From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 17 May 2011 13:02:47 +0200
Message-ID: <e6b52d895fca947b4cce2896d593619b@localhost>
References: <1305618020-72535-1-git-send-email-tsunanet@gmail.com>
 <1305618020-72535-2-git-send-email-tsunanet@gmail.com>
 <1305619677.2850.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Benoit Sigoure <tsunanet@gmail.com>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305619677.2850.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 17 May 2011 10:07:57 +0200, Eric Dumazet wrote:



> I wont discuss if introducing a new sysctl is welcomed, only on patch

> issues. I believe some work in IETF is done to reduce the 3sec value to

> 1sec anyway.



Why not? I though all new knobs in this area should be done on a per route

metric so it can be controlled on a per path basis. RTO should be

adjustable on a per path basis, because it depends on the path.



Some months back [1] I posted a patch to enable/disable TCP quick ack

mode, which has nothing to do with network paths, just with a local server

policy. But David rejected the patch with the argument that I should use a

per path knob (this is a little bit inapprehensible for me, but David has

the last word).



Hagen





[1] http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283640
