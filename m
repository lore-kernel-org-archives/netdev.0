From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] appletalk: Fix socket referencing in skb
Date: Tue, 08 Jul 2014 08:12:59 +0200
Message-ID: <1404799979.3515.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1404764570-24120-1-git-send-email-andrey.krieger.utkin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, acme@ghostprotocols.net,
	davem@davemloft.net
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:34891 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922AbaGHGNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 02:13:05 -0400
In-Reply-To: <1404764570-24120-1-git-send-email-andrey.krieger.utkin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-07 at 23:22 +0300, Andrey Utkin wrote:
> Setting just skb->sk without taking its reference and setting a
> destructor is invalid. However, in the places where this was done, skb
> is used in a way not requiring skb->sk setting. So dropping the setting
> of skb->sk.
> Thanks to Eric Dumazet <eric.dumazet@gmail.com> for correct solution.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=79441
> Reported-by: Ed Martin <edman007@edman007.com>
> Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
> ---

Thanks !

Signed-off-by: Eric Dumazet <edumazet@google.com>
