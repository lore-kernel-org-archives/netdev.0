From: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 25 Apr 2016 16:47:18 +0300
Message-ID: <CAKHjkjnTV-qp_48dkJ_isZH2zxL_1-Q7MUCuK1kg6-Nkhk6KAg@mail.gmail.com>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
	<20160419182212.GA8441@infradead.org>
	<571785A5.5040306@codeaurora.org>
	<CAKHjkjmYNLABO10V1DZQmZ_zczjbfDZU0TDPHoMmv_1FMi9_gA@mail.gmail.com>
	<CAJ3xEMiZ-L5OSogx_3fTSOt-chvYJw6ANtbxYJi5TFR-_H4U-g@mail.gmail.com>
	<20160421133903.GA19633@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Sinan Kaya <okaya@codeaurora.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	timur@codeaurora.org, cov@codeaurora.org,
	Yishai Hadas <yishaih@mellanox.com>,
	Haggai Abramovsky <hagaya@mellanox.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32943 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbcDYNrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 09:47:20 -0400
In-Reply-To: <20160421133903.GA19633@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 4:39 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Apr 21, 2016 at 04:37:42PM +0300, Or Gerlitz wrote:
>> On Wed, Apr 20, 2016 at 9:40 PM, Eran Ben Elisha
>> <eranlinuxmellanox@gmail.com> wrote:
>> >> It is been 1.5 years since I reported the problem. We came up with three
>> >> different solutions this week. I'd like to see a version of the solution
>> >> to get merged until Mellanox comes up with a better solution with another
>> >> patch. My proposal is to use this one.
>>
>> > We will post our suggestion here in the following days.
>>
>> To update, Haggai A from our driver team is working on a patch. He is
>> providing a copy for
>> testing over ARM to the folks that reported on the problem and will
>> post it here early next week.
>
> Any chance you could give feedback to the patch I posted this week?

Haggai just posted Mellanox fix to this issue.
Your suggestion discards the option to work with fragmented memory at
mlx4_ib, which is unnecessary.

Please see our suggestion, comments are welcome.
