From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Sun, 15 Feb 2004 18:00:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402F97B4.4010107@kolumbus.fi>
References: <Xine.LNX.4.44.0402150901460.12324-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402150901460.12324-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



James Morris wrote:

>On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:
>
> =20
>
>>skb_checksum_help() updates skb->ip_summed to CHECKSUM_NONE in the=20
>>original skb, and this should be seen by the driver. With your change=20
>>the checksum is calculated twice, once for the looping back packet, and=
=20
>>once for the outgoing.
>>   =20
>>
>
>[Looks like my posts are not making it to netdev]
>
>It updates ip_summed in the cloned packet header, but not in the origina=
l=20
>packet, which gets sent to the driver with an already completed checksum.
>
>See the original post.
>
>
>- James
>

ah, sorry, I see your point now. Maybe this copy should be in=20
skb_checksum_help() ?

--Mika
