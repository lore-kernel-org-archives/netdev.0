From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] udp: Simplify __udp*_lib_mcast_deliver.
Date: Wed, 16 Jul 2014 09:07:35 +0200
Message-ID: <1405494455.10255.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405481312-7790-1-git-send-email-drheld@google.com>
	 <1405481312-7790-2-git-send-email-drheld@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com
To: David Held <drheld@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:59155 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030499AbaGPHHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 03:07:41 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so419182wgh.34
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 00:07:40 -0700 (PDT)
In-Reply-To: <1405481312-7790-2-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 23:28 -0400, David Held wrote:
> Switch to using sk_nulls_for_each which shortens the code and makes it
> easier to update.
> 
> Signed-off-by: David Held <drheld@google.com>
> ---
>  net/ipv4/udp.c | 48 ++++++++++----------------------
>  net/ipv6/udp.c | 88 +++++++++++++++++++++++-----------------------------------
>  2 files changed, 49 insertions(+), 87 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
