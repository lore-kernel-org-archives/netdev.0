From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 20:24:02 +0100
Message-ID: <5a4c581d0901111124p753e0436q5dc3f4645e481c8b@mail.gmail.com>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
	 <20090109.140422.60087297.davem@davemloft.net>
	 <43805.1231672258@turing-police.cc.vt.edu>
	 <20090111.040842.86784676.davem@davemloft.net>
	 <1231676698.25018.147.camel@macbook.infradead.org>
	 <1231678799.25018.195.camel@macbook.infradead.org>
	 <5a4c581d0901110842i5520cea1uff89d5772d0f3b6e@mail.gmail.com>
	 <1231692789.25018.415.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, Valdis.Kletnieks@vt.edu,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:34724 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbZAKTYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 14:24:04 -0500
In-Reply-To: <1231692789.25018.415.camel@macbook.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 5:53 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Sun, 2009-01-11 at 17:42 +0100, Alessandro Suardi wrote:
>> Patches cleanly but doesn't build in 2.6.29-rc1:
>
> Pants; sorry, I omitted this bit...
>
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index ae5da60..508def3 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2764,6 +2764,7 @@ struct tg3 {
>        struct ethtool_coalesce         coal;
>
>        /* firmware info */
> +       const char                      *fw_needed;
>        const struct firmware           *fw;
>        u32                             fw_len; /* includes BSS */
>  };
>

This one works, thank you.

However, with the combination of in-kernel tg3 and
 CONFIG_IN_KERNEL_FIRMWARE=n there is at least a 30" delay
 during boot while waiting for the firmware request (which will fail).

Such wait didn't use to be there, and stuff worked. Could the wait
 be removed, to behave as it used to - as well ?

Thanks again, ciao,

--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")
