From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] Tarpit target for the last stable (2.6.35.7): right
 version
Date: Sat, 9 Oct 2010 06:21:44 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010090609350.1542@obet.zrqbmnf.qr>
References: <4CAF6A83.6090004@gmail.com> <1286565042.2282.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nicola <nicola.padovano@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1286565042.2282.6.camel@achroite.uk.solarflarecom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-10-08 21:10, Ben Hutchings wrote:
>On Fri, 2010-10-08 at 21:01 +0200, Nicola wrote:
>> [Sorry for the inconvenience: I just noticed that Gmail has a bad 
>> formatting. I resend the patch hoping that now things are right.]
>[...]
>
>It's still word-wrapped.  You may have to make the patch an attachment,
>but see Documentation/email-clients.txt for configuration hints.
>
>It is also not based on the right version; networking patches adding new
>features should be based on David Miller's net-next-2.6 tree.

I must say I am surprised.

There already exists a maintained xt_TARPIT in Xtables-addons, and
it seems like your patch is a duplicate effort of it.

If you have any updates to xt_TARPIT, I would recommend the strategy
that Luciano Coelho used when he wanted to have xt_condition in
the main kernel:

1. take the maintained version from Xt-a
2. submit any updates to the Xt-a file, if feasible
3. once processed, submit that then for Linux kernel inclusion
4. apply further updates to the LK file, if needed

That way it is way easier to know what specifically new features you 
have added to xt_TARPIT, if any.


thanks,
Jan
