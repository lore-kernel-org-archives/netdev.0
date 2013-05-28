From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net/usb/kalmia: use %*phC to dump small buffers
Date: Tue, 28 May 2013 21:21:10 +0300
Message-ID: <CAHp75Vfv7q7ACuS0_x0V1rwHTbvMcmYfgcJmFmrJpasFMMGXEQ@mail.gmail.com>
References: <1369734966-29026-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<51A4F3E9.4090108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	USB <linux-usb@vger.kernel.org>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33578 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab3E1SVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 14:21:12 -0400
In-Reply-To: <51A4F3E9.4090108@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 9:14 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 28-05-2013 13:56, Andy Shevchenko wrote:

>> @@ -263,32 +260,24 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff
>> *skb)
>>                                 sizeof(EXPECTED_UNKNOWN_HEADER_1)) ||
>> !memcmp(
>>                                 header_start, EXPECTED_UNKNOWN_HEADER_2,
>>                                 sizeof(EXPECTED_UNKNOWN_HEADER_2))) {
>> -                               netdev_dbg(
>> -                                       dev->net,
>> -                                       "Received expected unknown frame
>> header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
>> -                                       header_start[0], header_start[1],
>> -                                       header_start[2], header_start[3],
>> -                                       header_start[4], header_start[5],
>> +                               netdev_dbg(dev->net,
>> +                                       "Received expected unknown frame "
>> +                                       "header: %6phC. Package length:
>> %i\n",
>
>    Message strings shouldn't be broken, despite 80 chars limit (there's an
> exception for them in checkpatch.pl).

I'm glad to hear that checkpatch.pl is eventually fixed.
Will send patch v2 tomorrow.

--
With Best Regards,
Andy Shevchenko
