From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 14:19:29 -0800
Message-ID: <CAB=NE6WAmHqAYsh6rwyHdvZy3J6ck-uD_Kavk3qqy02vML359g@mail.gmail.com>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
 <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk> <20140224.235343.1936318499491821387.davem@davemloft.net>
 <2446186.I4KkJ8Hjdb@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2446186.I4KkJ8Hjdb@lenovo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 24, 2014 at 9:37 PM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> Le lundi 24 f=C3=A9vrier 2014, 23:53:43 David Miller a =C3=A9crit :
>> They are visible to userspace via sysfs.
>
> In /sys/class/net/*/flags, although we are lacking quite a lot of doc=
umentation
> for the exported attributes there.

I only see dev->flags there, I don't see any toggle capability for
priv_flags. Let me know if you find anywhere that userspace lets a
user toggle private flags, I just don't see it.

I'll extend the documentation for a v2 with the sysfs attribute stuff.

  Luis
