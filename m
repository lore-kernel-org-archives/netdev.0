From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Tue, 13 Jul 2010 21:58:00 +0800
Message-ID: <AANLkTimZyIhl34NzAZXMNUEmGy0KFCBs_LMk5qSBwrF2@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	<1278334254.2877.158.camel@edumazet-laptop> <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	<1278388580.2466.305.camel@edumazet-laptop> <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
	<AANLkTimRXMivugXHJswrT5FA93PIjSjU-RneFKs1bkLL@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7BAB@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49250 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab0GMN6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 09:58:21 -0400
Received: by vws5 with SMTP id 5so5834793vws.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 06:58:20 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7BAB@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 13, 2010 at 8:42 PM, Ofer Heifetz <oferh@marvell.com> wrote:
> Write and re-write numbers are in MBps.
> Iozone performs re-write meaning reads a chunk of data and writes it back, so basically the performance for this operation should be quiet high since kernel caches usage.
>
> I forgot to mention that I used EXT4 fs.

Maybe it is caused by this line in generic_file_splice_write():

                balance_dirty_pages_ratelimited_nr(mapping, nr_pages);

Please try to test it again without this line.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
