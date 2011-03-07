From: Jovi Zhang <bookjovi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: mac80211: fix compilation warning
Date: Mon, 7 Mar 2011 12:15:02 +0800
Message-ID: <AANLkTi=GHOyeSWA96UUokmYSdHHc5cuY53xJuhVzBNwz@mail.gmail.com>
References: <1299108754-5492-1-git-send-email-bookjovi@gmail.com>
	<1299328260.4277.92.camel@localhost>
	<AANLkTimnSvBKSL6_d3RxufxUL_C9wCM+Fz66_B5Sc0KE@mail.gmail.com>
	<4D72650D.8070503@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"open list:NETWORKING [WIREL..." <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING [GENERAL]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D72650D.8070503-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 6, 2011 at 12:30 AM, Larry Finger <Larry.Finger-tQ5ms3gMjBKDGRHsOpWV0g@public.gmane.org=
t> wrote:
> On 03/05/2011 07:52 AM, Jovi Zhang wrote:
>>
>> On Sat, Mar 5, 2011 at 8:31 PM, Ben Hutchings<bhutchings@solarflare.=
com>
>> =C2=A0wrote:
>>>
>>> On Wed, 2011-03-02 at 18:32 -0500, bookjovi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>>>
>>>> From: Jovi Zhang<bookjovi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>
>>>> this commit fix compilation warning as following:
>>>> net/mac80211/tx.c:1753: warning: unused variable mppath
>>>
>>> [...]
>>>
>>> You clearly didn't try building this with CONFIG_MAC80211_MESH enab=
led.
>>>
>> Sorry, indeed, maybe should be like this:
>>
>> +#ifdef CONFIG_MAC80211_MESH
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mesh_path *mppath =3D NULL;
>> +#endif
>
> Linville likes "struct mesh_path *mppath __maybe_unused =3D NULL;" ov=
er the
> ifdef form.

That's better, Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
