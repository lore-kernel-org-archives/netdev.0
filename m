From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_hashlimit: dl_seq_stop() fix
Date: Thu, 25 Mar 2010 11:01:56 +0100
Message-ID: <4BAB3494.4030402@trash.net>
References: <1269463664.2849.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269463664.2849.9.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> If dl_seq_start() memory allocation fails, we crash later in
> dl_seq_stop(), trying to kfree(ERR_PTR(-ENOMEM))

Seems pretty counter intuitive to me that ->stop is invoked after
->start returned an error.

Applied, thanks.
