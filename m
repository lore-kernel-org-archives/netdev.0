From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed, 07 Aug 2013 11:06:06 -0700
Message-ID: <1375898766.4004.37.camel@edumazet-glaptop>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1375897371-18430-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 19:42 +0200, Patrick McHardy wrote:

> 
> The SYNPROXY operates by marking the initial SYN from the client as UNTRACKED
> and directing it to the SYNPROXY target. The target responds with a SYN/ACK
> containing a cookie and encodes options such as window scaling factor, SACK
> perm etc. into the timestamp, if timestamps are used (similar to TCP). The
> window size is set to zero. The response is also sent as untracked packet.

TCP timestamps are not really used, for various reasons ...

Have you taken a look at 

<http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>



