From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] pppox: use standard module auto-loading feature
Date: Wed, 2 Dec 2015 17:13:09 +0100
Message-ID: <20151202161309.GA16101@alphalink.fr>
References: <02bfd73648a0cf563213d58daefe8b8de580a70a.1449067422.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Kozlov <xeb@mail.ru>, James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:46791 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbLBQNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:13:16 -0500
Content-Disposition: inline
In-Reply-To: <02bfd73648a0cf563213d58daefe8b8de580a70a.1449067422.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2015 at 04:27:39PM +0100, Guillaume Nault wrote:
>   * Register PF_PPPOX with pppox module rather than with pppoe,
>     so that pppoe doesn't get loaded for any PF_PPPOX socket.
> 
>   * Register PX_PROTO_* with standard MODULE_ALIAS_NET_PF_PROTO()
>     instead of using pppox's own naming scheme.
> 
>   * While there, add auto-loading feature for pptp.
> 
This is for net-next, sorry.
