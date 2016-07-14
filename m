From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] rndis_host: Set random MAC for ZTE MF910
Date: Thu, 14 Jul 2016 10:01:28 +0200
Message-ID: <CAKfDRXhDp3heiD75Lat7cr1JmY-kaJ-MS0tt7QXX=s8RFjbpUQ@mail.gmail.com>
References: <1468427945-11600-1-git-send-email-kristian.evensen@gmail.com>
 <87k2gpnpo5.fsf@miraculix.mork.no> <CAKfDRXiP=LpNqPi5nSoMM2BK510edvCoatRWQhnQ8Z66N40_iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKfDRXiP=LpNqPi5nSoMM2BK510edvCoatRWQhnQ8Z66N40_iw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14, 2016 at 9:54 AM, Kristian Evensen
<kristian.evensen@gmail.com> wrote:
> Hi Bj=C3=B8rn,
>
> On Thu, Jul 14, 2016 at 12:23 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>>
>> Or how about the more generic?:
>>
>>         if (bp[0] & 0x02)
>>                 eth_hw_addr_random(net);
>>         else
>>                 ether_addr_copy(net->dev_addr, bp);
>>
>> That would catch similar screwups from other vendors too.
>
> Great idea, thanks. After submitting the patch I found some other
> devices with a similar bug, and there are probably even more out
> there. I will update patch and resubmit.

Oh, and I forgot to say, please ignore this patch. I will change the
title and description to better describe the functionality.

-Kristian
