From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Mon, 16 Feb 2004 08:43:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403066A2.30705@kolumbus.fi>
References: <Xine.LNX.4.44.0402152048510.14031-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402152048510.14031-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



James Morris wrote:

>On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:
>
> =20
>
>>ah, sorry, I see your point now. Maybe this copy should be in=20
>>skb_checksum_help() ?
>>   =20
>>
>
>No, it's not needed by all callers, and is just a does-one-thing helper=20
>function.
>
>
>- James
>
It is needed for cloned skbs, so check for this should go in=20
skb_checksum_help().

--Mika
