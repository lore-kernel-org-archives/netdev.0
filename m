From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Thu, 03 Dec 2015 13:47:48 -0800
Message-ID: <1449179268.25029.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com>
	 <871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
	 <20151202.130244.140973474498435711.davem@davemloft.net>
	 <87zixrusxq.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zixrusxq.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-03 at 21:24 +0000, Rainer Weikusat wrote:

> As far as I can tell, yes. With the change, unix_dgram_recvmsg has a
> read loop looking like this:
> 
> 	last = NULL; /* not really necessary */


I am not sure SO_RCVTIMEO is really used for af_unix, given its poor
reaction to syscall restarts (ERESTARTSYS)

Do you really know applications relying on it ?
