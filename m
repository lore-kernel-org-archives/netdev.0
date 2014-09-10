From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: iwlwifi no authentication with AP - Re: pull request: wireless-next
 2014-09-08
Date: Wed, 10 Sep 2014 07:01:48 +0200
Message-ID: <540FDB3C.6060301@hartkopp.net>
References: <20140908191630.GB29412@tuxdriver.com>	<540F5927.7000306@hartkopp.net>	<CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>	<540F61D0.9000704@hartkopp.net> <CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10.09.2014 00:07, Vadim Kochan wrote:
> I have the same issue with iwlwifi.

I tried an old zd1211 wireless USB stick to check if this problem is 80211
related. But the USB stick works fine (I'm using it right now).
So its definitely looks like an iwlwifi issue.

> iwlwifi 0000:02:00.0: fail to flush all tx fifo queues Q 0

Wasn't there any change in the iwlwifi tx path recently??

Regards,
Oliver

> 
> On Tue, Sep 9, 2014 at 11:23 PM, Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
>> On 09.09.2014 22:02, Emmanuel Grumbach wrote:
>>> On Tue, Sep 9, 2014 at 10:46 PM, Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
>>>> Hello John, all,
>>>>
>>>> on my i7 Laptop with iwlwifi the latest net-next does not connect to my access point:
>>>
>>> Are you sure this wasn't the case before?
>>
>> Indeed I moved to net-next right today - as I also had the LED lockdep splat
>> on 3.17-rcX with X < 4.
>>
>> So it can be that this issue was already introduced at the beginning of this
>> net-next cycle. Don't know, sorry. The latest 3.17-rc4 from Linus' tree works
>> fine. I'm running a Debian unstable here (in both cases).
>>
>>> Can you bisect?
>>
>> Not really. I'm running the kernel on my bare machine - and I just wanted to
>> go to bed right now ...
>>
>> So I will be able to test patches tomorrow morning again.
>>
>> Tnx for your fast feedback,
>> Oliver
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
