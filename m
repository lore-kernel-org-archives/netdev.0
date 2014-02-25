From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 14:39:28 -0800
Message-ID: <CAGVrzcaaViC10TvnSVBJsKRF3pSOvbP7Z+Kh4Qcu0RS_RY5GBA@mail.gmail.com>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
 <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk> <20140224.235343.1936318499491821387.davem@davemloft.net>
 <2446186.I4KkJ8Hjdb@lenovo> <CAB=NE6WAmHqAYsh6rwyHdvZy3J6ck-uD_Kavk3qqy02vML359g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34788 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbaBYWkJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 17:40:09 -0500
In-Reply-To: <CAB=NE6WAmHqAYsh6rwyHdvZy3J6ck-uD_Kavk3qqy02vML359g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-25 14:19 GMT-08:00 Luis R. Rodriguez <mcgrof@do-not-panic.com>:
> On Mon, Feb 24, 2014 at 9:37 PM, Florian Fainelli <f.fainelli@gmail.c=
om> wrote:
>> Le lundi 24 f=C3=A9vrier 2014, 23:53:43 David Miller a =C3=A9crit :
>>> They are visible to userspace via sysfs.
>>
>> In /sys/class/net/*/flags, although we are lacking quite a lot of do=
cumentation
>> for the exported attributes there.
>
> I only see dev->flags there, I don't see any toggle capability for
> priv_flags. Let me know if you find anywhere that userspace lets a
> user toggle private flags, I just don't see it.

You are right, those are dev->flags, not priv_flags, sorry about that.

>
> I'll extend the documentation for a v2 with the sysfs attribute stuff=
=2E

Thanks!
--=20
=46lorian
