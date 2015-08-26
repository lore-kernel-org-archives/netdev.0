From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [[net-next] lo uses DEPRECATED zero tx_queue_len - convert driver
 to use IFF_NO_QUEUE instead
Date: Wed, 26 Aug 2015 12:16:47 +0200
Message-ID: <CAMuHMdVFNnfDFO0Kqz=N3rFW7_3O8ha3Da80bMaEeVozducw9w@mail.gmail.com>
References: <CAMuHMdX6O3_wtWagwAKgVd=aifXjVd5rw8VczF18VS9+Mm30oQ@mail.gmail.com>
	<20150826093426.GA20760@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34776 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756691AbbHZKQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 06:16:48 -0400
Received: by obbfr1 with SMTP id fr1so166719646obb.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 03:16:47 -0700 (PDT)
In-Reply-To: <20150826093426.GA20760@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

On Wed, Aug 26, 2015 at 11:34 AM, Phil Sutter <phil@nwl.cc> wrote:
> On Tue, Aug 25, 2015 at 01:16:41PM +0200, Geert Uytterhoeven wrote:
>> I don't know if this was reported before (I'm not subscribed to netdev), but
>> Google couldn't find it:
>>
>> lo uses DEPRECATED zero tx_queue_len - convert driver to use
>> IFF_NO_QUEUE instead
>
> This is fixed by commit e65db2b ("net: loopback: convert to using
> IFF_NO_QUEUE"), part of a bigger series converting drivers (see here:
> http://lists.openwall.net/netdev/2015/08/18/52).

Strange, that commit is included in my tree, which is based on
https://git.kernel.org/cgit/linux/kernel/git/geert/renesas-drivers.git/
and includes net-next?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
