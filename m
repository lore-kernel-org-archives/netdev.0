From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: [net-next.git 4/9] stmmac: add the support for PTP hw clock driver
Date: Tue, 12 Mar 2013 10:13:17 +0530
Message-ID: <CAJ3bTp76BX-nbk5E_QVyx--EPAWbf3JtORVTbwjcd0skndzbKg@mail.gmail.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
	<1362653419-1047-5-git-send-email-peppe.cavallaro@st.com>
	<20130310121050.GA2462@netboy.at.omicron.at>
	<CAJ3bTp7n-Y6TYrhDMe58fALtX5O34qifO9khWYXpo-OwnrRKiQ@mail.gmail.com>
	<20130311185536.GA2409@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, bh74.an@samsung.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:39135 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab3CLEnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 00:43:19 -0400
Received: by mail-we0-f181.google.com with SMTP id t44so4301261wey.40
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 21:43:18 -0700 (PDT)
In-Reply-To: <20130311185536.GA2409@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 12:25 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Sun, Mar 10, 2013 at 08:37:24PM +0530, Rayagond K wrote:
>> On Sun, Mar 10, 2013 at 5:40 PM, Richard Cochran <richardcochran@gmail.com>wrote:
>
>> > Don't you need locking here to protect against concurrent callers of
>> > config_addend?
>> >
>>
>> Yes we need locking here too, will add it.
>>
>> But I can see no locking in this function in other two driver'e
>> ppt_ixp46x.c and gianfar_ptp.c. So I just followed these two driver.
>
> Those two drivers don't need locking, because setting the addend
> register is a single 32 bit write operation in both cases.
>
> In your driver, setting the addend involves a sequence of writes and
> reads, in addition to polling a status bit, so you do need to
> serialize access to those registers.

Okay, will take lock in our driver. Thank you.

>
> Thanks,
> Richard
