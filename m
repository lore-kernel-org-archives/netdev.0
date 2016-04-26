From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: codel: split into multiple files
Date: Tue, 26 Apr 2016 08:43:34 +0200
Message-ID: <CA+icZUVinohrHUNpKti-QA52eeSztmRTH1sFHpK+YSm98yGrAA@mail.gmail.com>
References: <CA+icZUWrRbBJM3q7SzRSc2znAXZHr1JdXHD2j2POKvDin4=CZg@mail.gmail.com>
	<CA+BoTQn2h8XQ5PwTm4Zy2-6JZs-muW2FmA0kVWf9OYCYgQ3T2g@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jens Axboe <axboe@fb.com>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:36561 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcDZGnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 02:43:35 -0400
Received: by mail-vk0-f65.google.com with SMTP id n67so698608vkf.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 23:43:35 -0700 (PDT)
In-Reply-To: <CA+BoTQn2h8XQ5PwTm4Zy2-6JZs-muW2FmA0kVWf9OYCYgQ3T2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/16, Michal Kazior <michal.kazior@tieto.com> wrote:
> On 26 April 2016 at 08:09, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>> Hi,
>>
>> I had a very quick view on net-next.git#master (up to commit
>> fab7b629a82da1b59620470d13152aff975239f6).
>>
>> Commit in [1] aka "codel: split into multiple files" removed codel.h
>> but [2] and [3] have relicts to it.
>> Forgot to remove?
>
> codel.h was not removed. diffstat for codel.h is all red which I
> presume is why you thought of it as removed, see:
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/include/net/codel.h?id=d068ca2ae2e614b9a418fb3b5f1fd4cf996ff032
>

[ CC Jens ]

OK.
So what are the plans in the future?
Keep a "generic" codel.h (compatibility reasons?) for net or is it your split?

AFAICS I have seen a codel-implementation in block.git#wb-buf-throttle.
Does it make sense to have a more "super-generic" codel.h for re-use
(not only for net and block)?
Just a thought.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/axboe/linux-block.git/log/?h=wb-buf-throttle
[2] http://git.kernel.org/cgit/linux/kernel/git/axboe/linux-block.git/commit/?h=wb-buf-throttle&id=b8bc0478ddd6f32a09a2b1ff30f7c75605448638
[3] http://git.kernel.org/cgit/linux/kernel/git/axboe/linux-block.git/commit/?h=wb-buf-throttle&id=e26e88f9c125a9cd6d3df0087386992183c1f47e
