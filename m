From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [PATCH net-next] tcp: tcp_syn_flood_action() can be static
Date: Thu, 26 Mar 2015 13:32:04 +0200
Message-ID: <CAE1zot+PBKuW=puJuwR9L-8_ZM3uxMNWEbVLTRR1JvR=zUO8gA@mail.gmail.com>
References: <1427321327.25985.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38164 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbbCZLcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:32:05 -0400
Received: by wibgn9 with SMTP id gn9so80707161wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 04:32:04 -0700 (PDT)
In-Reply-To: <1427321327.25985.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 12:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> After commit 1fb6f159fd21 ("tcp: add tcp_conn_request"),
> tcp_syn_flood_action() is no longer used from IPv6.
>
> We can make it static, by moving it above tcp_conn_request()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Reviewed-by: Octavian Purdila <octavian.purdila@intel.com>
