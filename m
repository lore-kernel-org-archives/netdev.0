From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH 1/2] iwlwifi: convert hex_dump_to_buffer() to %*ph
Date: Tue, 4 Aug 2015 14:52:27 +0300
Message-ID: <CANUX_P202HpnSGbkPA=OT9=5GykhJ1u9u_Y2VwA3wnLi7=48_g@mail.gmail.com>
References: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1438685233.29746.156.camel@linux.intel.com>
	<CANUX_P3x1soE8PV9ZH4ObzgEzz9aEft6gS7mcVhbHRGy7H5mGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34691 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932776AbbHDLw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 07:52:29 -0400
In-Reply-To: <CANUX_P3x1soE8PV9ZH4ObzgEzz9aEft6gS7mcVhbHRGy7H5mGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2015 at 2:48 PM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
> On Tue, Aug 4, 2015 at 1:47 PM, Andy Shevchenko
> <andriy.shevchenko@linux.intel.com> wrote:
>> On Thu, 2015-07-16 at 15:42 +0300, Andy Shevchenko wrote:
>>> There is no need to use hex_dump_to_buffer() in the cases like this:
>>>
>>>       hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);      > /* len <= 16
>>> */
>>>       sprintf("%s\n", outbuf);
>>>
>>> since it maybe easily converted to simple:
>>>
>>>       sprintf("%*ph\n", len, buf);
>>>
>>> Note: it seems in one case the output is groupped by 2 bytes and
>>> looks like a
>>> typo. Thus, patch changes that to plain byte stream.
>>
>>
>> Any comments on this, anyone?
>>
>> The idea is to minimize usage of hexdump_to_buffer(), i.e. not using it
>> when it's an obvious overkill.
>>
>
> Sorry for the delay, since the buffer is small (less than 16 bytes, it
> should be fine).

I applied it on our internal tree. Thank you.
