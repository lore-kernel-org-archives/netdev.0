From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH 3/4] ps3_gelic: lower NAPI weight
Date: Wed, 21 Aug 2013 14:03:08 -0700
Message-ID: <1377118988.8674.82.camel@smoke>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>
	 <1377103771-1590-4-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38407 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab3HUVDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 17:03:16 -0400
In-Reply-To: <1377103771-1590-4-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 18:49 +0200, Michal Schmidt wrote:
> Since commit 82dc3c63 netif_napi_add() produces an error message if
> a NAPI poll weight greater than 64 is requested.
> 
> GELIC_NET_NAPI_WEIGHT is defined to GELIC_NET_RX_DESCRIPTORS,
> which is 128.
> 
> Use the standard NAPI weight.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Geoff Levand <geoff@infradead.org>
> ---
>  drivers/net/ethernet/toshiba/ps3_gelic_net.c | 3 +--
>  drivers/net/ethernet/toshiba/ps3_gelic_net.h | 1 -
>  2 files changed, 1 insertion(+), 3 deletions(-)

Change looks fine.  Please correct comment as Sergei
suggested.

Acked-by: Geoff Levand <geoff@infradead.org>
