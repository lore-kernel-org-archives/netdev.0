From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Sat, 13 Aug 2016 21:58:56 -0700
Message-ID: <CAM_iQpX8gsLkyQMJuYmoWu3Kp8808gTL16Lv6g8BZ=cO50FTkQ@mail.gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com> <CAM_iQpUCqzytG662vBd4D0Zx09CWA9a1VuZerTatMMhdy42jBA@mail.gmail.com>
 <62bb1c25-2967-dedc-89ac-01632d0e090d@mojatatu.com> <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
 <7d9ff1fb-90e3-6055-1560-1cf92e23f084@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33832 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbcHNJJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 05:09:08 -0400
Received: by mail-io0-f170.google.com with SMTP id q83so59249927iod.1
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 02:09:07 -0700 (PDT)
In-Reply-To: <7d9ff1fb-90e3-6055-1560-1cf92e23f084@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2016 at 4:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> I tested a lot more this time.
> Good news: performance regression now resolved.
> Some bad news - there's still one more oops:
>
> sudo $TC actions add action police rate 1kbit burst 90k drop index 1

Relax, Jamal, it is caused by other commit, not my previous one.

But I can definitely fix it since you are so busy. ;)
