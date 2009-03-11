From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Wed, 11 Mar 2009 09:27:16 -0700
Message-ID: <43e72e890903110927i2ef8012dn86e0e72fb048aea3@mail.gmail.com>
References: <20090223192659.GB3553@tuxdriver.com>
	 <1235457113.4455.89.camel@johannes.local>
	 <20090224.235510.30497146.davem@davemloft.net>
	 <1235637360.29050.16.camel@johannes.local>
	 <20090226161340.GA4430@tuxdriver.com>
	 <1235698640.4936.6.camel@johannes.local>
	 <43e72e890902261918p47e45b14i7528dd0f40685879@mail.gmail.com>
	 <1236772199.20266.3.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1236772199.20266.3.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 11, 2009 at 4:49 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Thu, 2009-02-26 at 19:18 -0800, Luis R. Rodriguez wrote:
>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&cfg80211_mtx)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock()
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_unlock()
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&cfg80211_mtx)
>> >
>> > to
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock()
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&cfg80211_mtx)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&cfg80211_mtx)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_unlock()
>> >
>> > everywhere.
>>
>> Sure, I'll give it a shot tomorrow unless someone else gets to it fi=
rst.
>
> Did you get a chance to look at this? Otherwise I'll just do it later
> today.

Unfortunately not, please do.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
