From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 27 Feb 2012 14:05:35 -0500 (EST)
Message-ID: <20120227.140535.1623396420455657443.davem@davemloft.net>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
	<20120224.153616.117399887784547022.davem@davemloft.net>
	<4F4B8C66.5060206@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier@collabora.co.uk, eric.dumazet@gmail.com,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	rodrigo.moya@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: javier.martinez@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4B8C66.5060206@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Date: Mon, 27 Feb 2012 15:00:06 +0100

> Primary for performance reasons. D-bus is an IPC system for processes in
> the same machine so traversing the whole TCP/IP stack seems a little
> overkill to me.

You haven't actually tested what the cost of this actually is, so what
you're saying is mere speculation.  In many cases TCP/UDP over
loopback is actually faster than AF_UNIX.

Since this is the premise of your whole rebuttal, I'll simply stop
reading here.
