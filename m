From: James Chapman <jchapman@katalix.com>
Subject: Re: problems with L2TP
Date: Thu, 09 Jul 2015 11:33:41 +0100
Message-ID: <559E4E05.3090902@katalix.com>
References: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>	<20150703154155.GA19294@jackdaw>	<CAKaJLVss0SMqf5hcBCdBuwa7+3_iBh527DW4+2Vb-RUPcb9Ffg@mail.gmail.com>	<559CF533.2060204@katalix.com> <CAKaJLVvft6HjFH+qAr4taD4bEis4SCtTSbvmDYuGz9=1boQvJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Tom Parkin <tparkin@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: Sam Protsenko <semen.protsenko@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:58295 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbbGIKdp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 06:33:45 -0400
In-Reply-To: <CAKaJLVvft6HjFH+qAr4taD4bEis4SCtTSbvmDYuGz9=1boQvJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/15 10:16, Sam Protsenko wrote:
>> Tom and I discussed this and we're not clear what you are running. Have
>> you changed create_pppox() in mtpd with the code fragment from your
>> original mail?
> Here is the commit for mtpd where I'm changing Android L2TP
> implementation to mainline implementation:
> http://git.linaro.org/people/semen.protsenko/mtpd.git/blobdiff/27a25e28b7c84d3f49c50a3e7b1fc3a46ac4ff51..01265f20617e7f3ca041e55dbf557912a0ecebd5:/l2tp_up.c
>
>> Are you sure that your modified mtpd gets the correct
>> local/remote tunnel-id and session-id to make its connect() call?
> Judging from xl2tpd and mtpd logs, they are actually different. Seems
> like this is actual issue. But I still didn't figured why it's
> happening.
> As I understand, mtpd should have the same values for remote
> tunnel-id/session-id as xl2tpd has for local ones, but it's not the
> case for my code.
That's correct. This is a control protocol implementation issue, not a
kernel issue.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
