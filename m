From: Luis Felipe Strano Moraes <lfelipe@profusion.mobi>
Subject: Re: [PATCH] Cleaning up code formatting errors in net/wireless
 pointed out by checkpatch.
Date: Fri, 17 Feb 2012 13:56:33 -0200
Message-ID: <CAHPwkG0yFX7Cac0NVc8obZ8N-07gck7bkTTCZvpCzY27wj1nzg@mail.gmail.com>
References: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6E75@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E75@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 February 2012 13:47, David Laight <David.Laight@aculab.com> wrote=
:
>
>> These are mostly minor changes and they are being sent as one
>> patch only in order to cause the smallest amount of disruption.
>
> A lot of these changes don't seem to match what I thought the
> linux kernel code style is.
>
> eg:
>> =A0void cfg80211_bss_age(struct cfg80211_registered_device *dev,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long age_secs)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long age_secs);
> Args no longer lined up.

It's ligned up here, perhaps mine (or yours) mail client is screwing
something up. This one was basically using tabs where they were
supposed to be.

>
>> - =A0 =A0 =A0 =A0 =A0 =A0 pos =3D (u8 *) & hdr->addr4;
>> + =A0 =A0 =A0 =A0 =A0 =A0 pos =3D (u8 *) &hdr->addr4;
> no space after cast?

There is a space there. The problem pointed by checkpatch was the
space between '&' and hdr.

>
>> - =A0 =A0 p1 =3D (u8*)(ht_capa);
>> + =A0 =A0 p1 =3D (u8 *)(ht_capa);
> Still extra ().
>
> I'm also not sure (personally) this sort of churn is useful.

As mentioned, those are mostly minor changes based on checkpatch's
output. Cleaning up only things that were specifically marked as
errors (so the extra parentheses there were not reported).

I don't think having lots of this kind of churn useful, thats why I
sent one patch only for the entire directory trying to clean up as
much as possible. There are some errors that I didn't clean up, but
they are mostly where an option was made on the source code to keep
code in a more readable way.

--lf


>
> =A0 =A0 =A0 =A0David
>
>



--=20
Lu=EDs Felipe Strano Moraes
Project Manager @ ProFUSION embedded systems
http://profusion.mobi
