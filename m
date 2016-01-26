From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RESEND net] nfc: use GFP_USER for user-controlled kmalloc
Date: Wed, 27 Jan 2016 10:15:57 +1100
Message-ID: <CAGRGNgXSbo1ZjFda5qyg8cesddTSUO2=rMEsopzHDuVBpHJqaA@mail.gmail.com>
References: <1453830820-27104-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAGRGNgV7MUXdk+e8Arx05yiWX6owei5dmnFQ-TBfs55jfy+qBw@mail.gmail.com> <CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Cong,

On Wed, Jan 27, 2016 at 10:12 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Jan 26, 2016 at 2:55 PM, Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Hi Cong,
>>
>> On Wed, Jan 27, 2016 at 4:53 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> A commit message would be nice. A brief rundown of how this is called
>> from userspace would be nice (I'm talking a single sentence here, e.g.
>> "this is allocated when submitting a nfc packet") and what issue
>> __GFP_NOWARN is fixing. (I'm guessing log spam due to allocation
>> failures.)
>>
>
> I thought it is obvious. ;) Keep in mind that $subject is one part of commit
> message too, so there is a commit message although very short.
>
> I will add it.

I know almost nothing about how the NFC subsystem works, and this
looks like a potential security issue, so more information is better
IMHO.

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
