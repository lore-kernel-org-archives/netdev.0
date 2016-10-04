From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mwifiex: report wakeup for wowlan
Date: Tue, 04 Oct 2016 15:46:03 +0300
Message-ID: <87vax8p9is.fsf@kamboji.qca.qualcomm.com>
References: <1475027104-17423-1-git-send-email-rajatja@google.com>
        <20161003130407.4D94161803@smtp.codeaurora.org>
        <CACK8Z6Fe34xdvd5-=3dNmqKXYC=Qr9+kpG46eCV7uFArLW+yyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Wei-Ning Huang <wnhuang@google.com>,
        Brian Norris <briannorris@google.com>,
        Eric Caruso <ejcaruso@chromium.org>,
        Rajat Jain <rajatxjain@gmail.com>
To: Rajat Jain <rajatja@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46043 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbcJDMqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 08:46:13 -0400
In-Reply-To: <CACK8Z6Fe34xdvd5-=3dNmqKXYC=Qr9+kpG46eCV7uFArLW+yyQ@mail.gmail.com>
        (Rajat Jain's message of "Mon, 3 Oct 2016 17:16:19 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rajat Jain <rajatja@google.com> writes:

> Hello Kalie,
>
> On Mon, Oct 3, 2016 at 6:04 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Rajat Jain <rajatja@google.com> wrote:
>>> Enable notifying wakeup source to the PM core in case of
>>> a wake on wireless LAN event.
>>>
>>> Signed-off-by: Wei-Ning Huang <wnhuang@google.com>
>>> Signed-off-by: Rajat Jain <rajatja@google.com>
>>> Tested-by: Wei-Ning Huang <wnhuang@chromium.org>
>>> Reviewed-by: Eric Caruso <ejcaruso@chromium.org>
>>> Acked-by: Amitkumar Karwar <akarwar@marvell.com>
>>
>> The commit log doesn't give any background info. Does this fix a bug or
>> why is it needed?
>
> Some of chromeos' features (called "darkresume" in chromeos
> terminology) use and track the wake up sources using the wakeup
> attributes in sysfs. Since the wireless device can wake up the host,
> hence we wanted to add it as a wakeup source to the system, and in the
> case of an actual wakeup event, trigger to the PM core that it was
> indeed caused by the device and it increments the different counters
> etc. In the absence of this patch,  the feature wasn't working very
> well (as it was apparently confused about the cause of wake up).

Thanks, makes sense. Please add that to the commit and send v3.

-- 
Kalle Valo
