From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] pktgen: Fix position of ip and udp header
Date: Tue, 04 Jun 2013 00:03:00 +0200
Message-ID: <51AD1294.8090604@redhat.com>
References: <08fe3153790311fbd98b1570a3e8134ddaac58a3.1370296008.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Simon Horman <horms@verge.net.au>,
	Daniel Borkmann <dborkmann@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412Ab3FCWDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 18:03:39 -0400
In-Reply-To: <08fe3153790311fbd98b1570a3e8134ddaac58a3.1370296008.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 11:49 PM, Thomas Graf wrote:
> skb_set_network_header() expects an offset based on the data pointer
> whereas skb_tail_offset() also includes the headroom. This resulted
> in the ip header being written in a wrong location.
>
> Use return values of skb_put() directly and rely on skb->len to
> set mac, network, and transport header.
>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Daniel Borkmann <dborkmann@redhat.com>
> Assisted-by: Daniel Borkmann <dborkmann@redhat.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks !

Acked-by: Daniel Borkmann <dborkmann@redhat.com>
