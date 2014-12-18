From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v2] net: ipv6: allow explicitly choosing optimistic addresses
Date: Thu, 18 Dec 2014 14:24:09 +0900
Message-ID: <CAKD1Yr3S7djuqVtS7hTBn552kEW+wedHCyop_oEv+EP_rzN5SA@mail.gmail.com>
References: <1418810135-12198-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:58460 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaLRFYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 00:24:30 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so498806ier.13
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 21:24:29 -0800 (PST)
In-Reply-To: <1418810135-12198-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 6:55 PM, Erik Kline <ek@google.com> wrote:
> This change makes optimistic addresses treated more like
> deprecated addresses than tentative ones.
>
> Signed-off-by: Erik Kline <ek@google.com>

This looks correct now. Adding the extra shim function is clearly less
churn than the alternative of changing all the callers (20 files) to
pass in the extra argument, though it's true that the resulting code
is a bit less elegant.

Acked-by: Lorenzo Colitti <lorenzo@google.com>
