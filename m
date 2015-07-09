From: Sam Protsenko <semen.protsenko@linaro.org>
Subject: Re: problems with L2TP
Date: Thu, 9 Jul 2015 12:16:47 +0300
Message-ID: <CAKaJLVvft6HjFH+qAr4taD4bEis4SCtTSbvmDYuGz9=1boQvJA@mail.gmail.com>
References: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>
	<20150703154155.GA19294@jackdaw>
	<CAKaJLVss0SMqf5hcBCdBuwa7+3_iBh527DW4+2Vb-RUPcb9Ffg@mail.gmail.com>
	<559CF533.2060204@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Parkin <tparkin@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37541 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbGIJQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 05:16:48 -0400
Received: by igau2 with SMTP id u2so84663333iga.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 02:16:48 -0700 (PDT)
In-Reply-To: <559CF533.2060204@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Tom and I discussed this and we're not clear what you are running. Have
> you changed create_pppox() in mtpd with the code fragment from your
> original mail?

Here is the commit for mtpd where I'm changing Android L2TP
implementation to mainline implementation:
http://git.linaro.org/people/semen.protsenko/mtpd.git/blobdiff/27a25e28b7c84d3f49c50a3e7b1fc3a46ac4ff51..01265f20617e7f3ca041e55dbf557912a0ecebd5:/l2tp_up.c

> Are you sure that your modified mtpd gets the correct
> local/remote tunnel-id and session-id to make its connect() call?

Judging from xl2tpd and mtpd logs, they are actually different. Seems
like this is actual issue. But I still didn't figured why it's
happening.
As I understand, mtpd should have the same values for remote
tunnel-id/session-id as xl2tpd has for local ones, but it's not the
case for my code.
