From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [Bug?] Machine hangs, rtl8192se possible cause
Date: Mon, 01 Aug 2011 22:45:09 -0500
Message-ID: <4E3772C5.70606@lwfinger.net>
References: <CAFdoEiT54o+NQKO=dAcOXgyf6GJ1E51w_H_p7PJyRmynz8Sbzg@mail.gmail.com>	<4E36C693.6000705@lwfinger.net> <CAFdoEiRBPMx0C+YXwd4-Q=_nHpOb+r2+GspwujZrPh6S4tDwEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jaroslaw Fedewicz <jafd-cTM//Nd5/DKCo84Yma55WQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFdoEiRBPMx0C+YXwd4-Q=_nHpOb+r2+GspwujZrPh6S4tDwEQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2011 06:10 PM, Jaroslaw Fedewicz wrote:
>
> I'm using a fairly recent version of kernel from git (I think from
> before yesterday). The mysterious hangs were there from the beginning,
> but it also might be partly because ATI driver was messed up too at
> these times. Later, ati appeared fixed but the hangs wouldn't go away.

If that git tree is linux-2.6, or its new name, from Linus, then you have the 
latest source.

> I don't think it's a panic proper, though. Nothing ever gets logged
> along the lines of "panic". Even if I happen to have a text mode
> console, it just freezes. If I have a panic or an oops proper, I'm
> also kicked out of X11 to see it by the KMS. But not in this case.
>
> (Also, the laptop has neither Caps Lock nor Num Lock nor Scroll Lock
> LEDs, so I can't see if they blink.)

A kernel panic never logs anything to the disk. The only place you will see it 
is on the logging console, or in netconsole output.

> What raised my suspicions is that I've never seen this happen when
> rtl8192se wasn't compiled at all or was not loaded.
>
> The most problematic thing is that it does not hang right away. Most
> of the time, I see the machine go into the catatonia after quite a
> while, and as it is not the laptop I do most of my work on, I usually
> see it hanged when screen PM has already kicked in. So I cannot really
> read what the log might say on the matter.
>
> I cannot also trigger the freeze reliably. Most of the time it happens
> "when you are not looking at it", and it usually happens either during
> or just after high load averages and low to none network activity (a
> typical scenario: build a firefox from sources, go outside, come home
> 4 hours later, the laptop is turned on but dead by hanging; no
> messages as the screen is obviously off; a less typical scenario is to
> freeze during startup).
>
> I'm the last person ever to suggest anything on the subject, but could
> it be a problem in the card's power management?

Not likely. I have three different cards with differing configurations that I 
have run for extended periods without seeing your problem. One of them is the 
same as yours.

Until you get some kind of dump from the system, I'm not sure what can be done.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
