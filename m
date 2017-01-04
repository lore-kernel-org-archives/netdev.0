From: Guan Xin <guanx.bac@gmail.com>
Subject: Re: ping: What's the purpose of rate limit?
Date: Wed, 4 Jan 2017 11:27:10 +0100
Message-ID: <CANeMGR7hLZ2+Mi7CW0dWQuNjcxjLdBzoP8nfFvaaQ-bZpNuEUQ@mail.gmail.com>
References: <CANeMGR4=vycxBU+LcrL2JXHt2FTYBkU2aLxfY5XRzHdws-aYag@mail.gmail.com>
 <CAM_iQpWBs1eUwfLprSsEFAtpMUWPY-jgXswzoHGck0DxxPQdZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:34096 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935063AbdADKge (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:36:34 -0500
Received: by mail-wj0-f179.google.com with SMTP id tn15so7094207wjb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 02:36:33 -0800 (PST)
In-Reply-To: <CAM_iQpWBs1eUwfLprSsEFAtpMUWPY-jgXswzoHGck0DxxPQdZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 7:45 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Hi,
>
> On Sat, Dec 31, 2016 at 4:04 AM, Guan Xin <guanx.bac@gmail.com> wrote:
>> Hello,
>>
>> Excuse me, I searched but didn't find an answer --
>>
>> What's the purpose of setting a limit to the "-i" and "-l" parameters
>> of ping for non-root users?
>>
>> It seems that this is only intended to prevent accidental misuse
>> because these restrictions can be easily worked around by starting
>> multiple instances or wrapping the program in a loop, e.g.,
>> while true; do ping -l3 -c3 192.168.0.1; done
>>
>
> I think the purpose of "-i" is not for rate limit, but for either hear beating
> or monitoring latency periodically.
>

Thanks for the reply! Probably I didn't make myself clear --
I meant the limit of 0.2s of the argument to -i for non-root users.

(Please Cc to me because I'm not subscribed to this list. Thanks!)

Regards,
Guan
