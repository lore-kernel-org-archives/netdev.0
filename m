From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 14:48:43 -0400
Message-ID: <CADZpyizwozRjYOvOads0KkqRr2quTo532TC=Ff=cw0sGc3OCQg@mail.gmail.com>
References: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
	<20120418.001650.1042781402985153056.davem@davemloft.net>
	<CADZpyixnQMM5WFWLyvEQ=D-tvrqFGe4PC5WdUzxVtdL96NODJQ@mail.gmail.com>
	<20120418.133102.1711079292327461659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120418.133102.1711079292327461659.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2012 at 1:31 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
> Date: Wed, 18 Apr 2012 08:57:58 -0400
>
>> In summary your opinion is that the API has and always will allow up
>> to 108 chars to be used in sun_path?
>
> Yes.
>
>> In which case I will talk to the Austin group to get a good example
>> added to POSIX showing safe usage.
>
> Why would you add language to POSIX for Linux specific behavior?
> Just curious :-)

Why not? Do you ever feel crazy when people question what you think is
perfectly reasonable? ;-)

POSIX doesn't exist in a vacuum, we need to harmonize reality with the
standard. If an implementation exists where sun_path has no
null-terminator then it is useful to have POSIX clarify that
null-termination is implementation defined behaviour, just like it
says that sun_path's length undefined. Under "Application Usage" or
"Examples" it's valid to talk about specific implementations.

See: http://pubs.opengroup.org/onlinepubs/007904975/basedefs/sys/un.h.html,
where it talks about BSD in the "Application Usage." It's about time
we some "Linux this" and "Linux that" in there.

Cheers,
Carlos.
