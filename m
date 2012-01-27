From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH v2] Allow ipv6 proxies and arp proxies be shown with
 iproute2
Date: Fri, 27 Jan 2012 05:35:21 -0500
Message-ID: <20120127103521.GA21240@canuck.infradead.org>
References: <1327652938-37078-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@parallels.com, devel@openvz.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Tony Zelenoff <antonz@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:44065 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758Ab2A0KfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 05:35:25 -0500
Content-Disposition: inline
In-Reply-To: <1327652938-37078-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2012 at 12:28:58PM +0400, Tony Zelenoff wrote:
> Add ability to return neighbour proxies list to caller if
> it sent full ndmsg structure and has NTF_PROXY flag set.
> 
> Before this patch (and before iproute2 patches):
> $ ip neigh add proxy 2001::1 dev eth0
> $ ip -6 neigh show
> $
> 
> After it and with applied iproute2 patches:
> $ ip neigh add proxy 2001::1 dev eth0
> $ ip -6 neigh show
> 2001::1 dev eth0  proxy
> $
> 
> Compatibility with old versions of iproute2 is not broken,
> kernel checks for incoming structure size and properly
> works if old structure is came.
> 
> [v2]
> * changed comments style.
> * removed useless line with continue and curly bracket.
> * changed incoming message size check from equal to more or
>   equal.
> 
> CC: davem@davemloft.net
> CC: kuznet@ms2.inr.ac.ru
> CC: netdev@vger.kernel.org
> CC: xemul@parallels.com
> Signed-off-by: Tony Zelenoff <antonz@parallels.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
