From: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Wed, 20 Feb 2013 07:26:01 +0100
Message-ID: <CA+XFjipJHGTvzUx6yy1DTc74kbrPEQxM08zW=N1uf43=Q6pwdg@mail.gmail.com>
References: <20130219.005206.397289032011003833.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com>
 <5123BCFF.5090408@lwfinger.net> <20130219.131553.787630407148880340.davem@davemloft.net>
 <5123C43D.2020602@lwfinger.net> <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com>
 <512437FA.2030105@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <512437FA.2030105-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 20, 2013 at 3:42 AM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
> On 02/19/2013 06:47 PM, Julian Calaby wrote:
>>
>>
>> Is it be possible to increase the number of slots at runtime? Maybe an
>> even better solution would be to keep the existing number of slots,
>> and if they run out, reset and increase incrementally to some sensible
>> maximum value.
>
>
> The number could be increased a bit, but on systems with 32-bit DMA such as
> the BCM4318, the maximum size of the ring buffer is 4KB. Even more
> importantly, each slot is allocated an skb of 2390 bytes. Even at 256 slots,
> the memory allocation is pretty large.
>
> Larry
>

Is this an issue that vendor drivers are also vulnerable to? If it is
a firmware issue, I would certainly think so.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
