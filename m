From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 1/4] net: diag: split inet_diag_dump_one_icsk into two
Date: Tue, 15 Dec 2015 09:44:06 -0800
Message-ID: <1450201446.8474.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
	 <1450199868-93712-1-git-send-email-lorenzo@google.com>
	 <1450199868-93712-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34184 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbbLORoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:44:08 -0500
Received: by mail-pf0-f171.google.com with SMTP id o64so8273168pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:44:08 -0800 (PST)
In-Reply-To: <1450199868-93712-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 02:17 +0900, Lorenzo Colitti wrote:
> Currently, inet_diag_dump_one_icsk finds a socket and then dumps
> its information to userspace. Split it into a part that finds the
> socket and a part that dumps the information.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/linux/inet_diag.h |  5 +++++
>  net/ipv4/inet_diag.c      | 42 +++++++++++++++++++++++++++---------------
>  2 files changed, 32 insertions(+), 15 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
