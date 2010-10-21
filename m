From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] tproxy: kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Thu, 21 Oct 2010 12:45:58 +0200
Message-ID: <4CC019E6.10202@trash.net>
References: <20101020112142.6538.25550.stgit@este.odu> <20101020112142.6538.90622.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101020112142.6538.90622.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.10.2010 13:21, schrieb KOVACS Krisztian:
> Without tproxy redirections an incoming SYN kicks out conflicting
> TIME_WAIT sockets, in order to handle clients that reuse ports
> within the TIME_WAIT period.
> 
> The same mechanism didn't work in case TProxy is involved in finding
> the proper socket, as the time_wait processing code looked up the
> listening socket assuming that the listener addr/port matches those
> of the established connection.
> 
> This is not the case with TProxy as the listener addr/port is possibly
> changed with the tproxy rule.

Applied, thanks.
