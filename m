From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: ipv6: more places need LOOPBACK_IFINDEX for flowi6_iif
Date: Mon, 28 Apr 2014 12:17:13 -0700
Message-ID: <CAHA+R7PXpweyfVMuGazCvHFXTRX-SGGjuXcU1tM-yy+oX1f=ng@mail.gmail.com>
References: <1398671516-8842-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:50312 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaD1TRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:17:16 -0400
Received: by mail-lb0-f171.google.com with SMTP id u14so2453854lbd.30
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 12:17:13 -0700 (PDT)
In-Reply-To: <1398671516-8842-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 12:51 AM, Julian Anastasov <ja@ssi.bg> wrote:
> To properly match iif in ip rules we have to provide
> LOOPBACK_IFINDEX in flowi6_iif, not 0. Some ip6mr_fib_lookup
> and fib6_rule_lookup callers need such fix.
>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Maybe ip6_mr_input() and pim6_rcv() too?
