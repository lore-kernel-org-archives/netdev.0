From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 9/9] tproxy: use the interface primary IP address as
 a default value for --on-ip
Date: Thu, 21 Oct 2010 16:21:53 +0200
Message-ID: <4CC04C81.9080504@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu> <20101021104710.5192.65152.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021104710.5192.65152.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.10.2010 12:47, schrieb KOVACS Krisztian:
> From: Balazs Scheidler <bazsi@balabit.hu>
> 
> The REDIRECT target and the older TProxy versions used the primary address
> of the incoming interface as the default value of the --on-ip parameter.
> This was unintentionally changed during the initial TProxy submission and
> caused confusion among users.
> 
> Since IPv6 has no notion of primary address, we just select the first address
> on the list: this way the socket lookup finds wildcard bound sockets
> properly and we cannot really do better without the user telling us the
> IPv6 address of the proxy.
> 
> This is implemented for both IPv4 and IPv6.


Also applied, thanks a lot.

