From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] tcp: bind() use stronger condition for bind_conflict
Date: Wed, 28 Mar 2012 23:08:00 +0300
Message-ID: <CAEnQRZD+0AQFfFCzWZCR5JR0BUxxNEsincD+_O9F0ne2Zryp_w@mail.gmail.com>
References: <1332882712-10756-1-git-send-email-alex.mihai.c@gmail.com>
	<20120328105212.1cb8dfe5@asterix.rh>
	<1332946113.2325.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexandru Copot <alex.mihai.c@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fbl@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332946113.2325.9.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2012 at 5:48 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Wed, 2012-03-28 at 10:52 -0300, Flavio Leitner wrote:
>> On Wed, 28 Mar 2012 00:11:52 +0300
>> Alexandru Copot <alex.mihai.c@gmail.com> wrote:
>>
>
>> > diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_con=
nection_sock.c
>> > index 02dd203..dfc8bc3 100644
>> > --- a/net/ipv6/inet6_connection_sock.c
>> > +++ b/net/ipv6/inet6_connection_sock.c
>> > @@ -28,7 +28,8 @@
>> > =A0#include <net/inet6_connection_sock.h>
>> >
>> > =A0int inet6_csk_bind_conflict(const struct sock *sk,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct inet_bi=
nd_bucket *tb)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct inet_bi=
nd_bucket *tb,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int relax)
>>
>> Same here
>> Maybe you can wait for more feedbacks before spin another patch
>> version just to fix that.
>>
>
>
>
> Also 'int relax' should be 'bool relax'... 1/0 -> true/false
>
> Anyway net-next is not open yet...

Eric, Flavio, thanks a lot for your comments. We will resubmit this
when net-next opens.

Please let us know if you have any other observations.

thanks,
Daniel.
