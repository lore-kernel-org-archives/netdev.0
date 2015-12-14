From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 4/4] net: diag: Support destroying TCP sockets.
Date: Mon, 14 Dec 2015 10:03:03 -0800
Message-ID: <1450116183.8474.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
	 <1450114197-73779-1-git-send-email-lorenzo@google.com>
	 <1450114197-73779-5-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34780 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbbLNSDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 13:03:06 -0500
Received: by pfbo64 with SMTP id o64so30470322pfb.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 10:03:05 -0800 (PST)
In-Reply-To: <1450114197-73779-5-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-15 at 02:29 +0900, Lorenzo Colitti wrote:

> +config INET_DIAG_DESTROY
> +	bool "INET: allow privileged process to administratively close sockets"
> +	depends on INET_DIAG && (IPV6 || IPV6=n)
> +	default n

I can see the effect of (IPV6 || IPv6=n) for a tristate,
but what is the intent for a bool ?

It seems INET_DIAG_DESTROY can be selected regardless of IPV6 being off,
on, or a module ?
