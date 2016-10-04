From: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v2] mwifiex: report wakeup for wowlan
Date: Mon, 3 Oct 2016 17:16:19 -0700
Message-ID: <CACK8Z6Fe34xdvd5-=3dNmqKXYC=Qr9+kpG46eCV7uFArLW+yyQ@mail.gmail.com>
References: <1475027104-17423-1-git-send-email-rajatja@google.com> <20161003130407.4D94161803@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Rajat Jain <rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161003130407.4D94161803-4h6buKAYkuurB/BPivuO70B+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Kalie,

On Mon, Oct 3, 2016 at 6:04 AM, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> Enable notifying wakeup source to the PM core in case of
>> a wake on wireless LAN event.
>>
>> Signed-off-by: Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> Tested-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> Reviewed-by: Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> Acked-by: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>
> The commit log doesn't give any background info. Does this fix a bug or
> why is it needed?

Some of chromeos' features (called "darkresume" in chromeos
terminology) use and track the wake up sources using the wakeup
attributes in sysfs. Since the wireless device can wake up the host,
hence we wanted to add it as a wakeup source to the system, and in the
case of an actual wakeup event, trigger to the PM core that it was
indeed caused by the device and it increments the different counters
etc. In the absence of this patch,  the feature wasn't working very
well (as it was apparently confused about the cause of wake up).

Thanks,

Rajat
