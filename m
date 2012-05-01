From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 01 May 2012 19:10:44 +0200
Message-ID: <1335892244.22133.27.camel@edumazet-glaptop>
References: <1335863465.11396.45.camel@edumazet-glaptop>
	 <20120501095914.0e60ff6a@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63978 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877Ab2EARKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:10:48 -0400
Received: by bkcji2 with SMTP id ji2so1066200bkc.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 10:10:47 -0700 (PDT)
In-Reply-To: <20120501095914.0e60ff6a@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 09:59 -0700, Stephen Hemminger wrote:

> The concept is fine, but a couple of questions.
>  1. Why a whole u32 for boolean?

a boolean in this structure wont save space, and this file is full of
u32. Why bother ?

IMHO boolean are fine for function arguments, but in a structure, not
very helpful.

>  2. The logic in this part of netem is setup to handle case of random duplication
>     combined with random loss. With ecn option set, will this code correctly
>     handled a duplication combined with a loss and send one packet?
>     It looks like the new code would change that behaviour.

Hmm, I'll take a look.
