From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Mon, 11 Feb 2013 13:57:59 +0100
Message-ID: <9EFD8AF1-2EDC-4361-A6CA-52FD5D42ED9E@ipflavors.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com> <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu> <20130207104908.GA17794@secunet.com> <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu> <20130207125437.GC17794@secunet.com> <1854603B-3AD1-4245-A8BA-53D841BCEA63@telecom-bretagne.eu>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <j.hadi123@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	Emmanuel THIERRY <emmanuel.thierry@telecom-bretagne.eu>,
	linux-kernel@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1854603B-3AD1-4245-A8BA-53D841BCEA63@telecom-bretagne.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steffen,

Do you plan to resubmit a patch to the mailing list or shall we take ca=
re of that?

Thank you,
Romain

On Feb 8, 2013, at 15:16 , Emmanuel Thierry <emmanuel.thierry@telecom-b=
retagne.eu> wrote:

> Hello,
>=20
> Le 7 f=E9vr. 2013 =E0 13:54, Steffen Klassert <steffen.klassert@secun=
et.com> a =E9crit :
>=20
>> On Thu, Feb 07, 2013 at 12:08:22PM +0100, Emmanuel Thierry wrote:
>>>=20
>>> This is a nice idea, however you keep the insertion asymmetric. The=
 usage of xfrm marks in non-conflicting cases will be made possible, bu=
t it stays disturbing for a user as the initial example will still have=
 the same behavior:
>>> * Inserting the marked one then the unmarked will succeed
>>> * Inserting the unmarked then the marked one will fail
>>> This gives to the user the feeling of an indeterministic behavior o=
f the xfrm module.
>>=20
>> This was intended. Inserting the marked one then the unmarked
>> is a working scenario. Some users might rely on it, so we can't
>> change this as you proposed.
>>=20
>> On the other hand, inserting the unmarked one then the marked
>> might result in a wrong policy lookup, so we can't allow this.
>> The only possibility we have, is inserting with different
>> priorites and that's what I'm proposing.
>>=20
>> I fear we have to live with that asymmetric behaviour if
>> both policies have the same priority.
>>=20
>=20
> Ok, actually i understand the concern of backward compatibility you e=
xpose. It is true that users might be disturbed if we change such a beh=
avior they would rely on.
> Anyway, i'm ok with your patch.
>=20
> Best regards
> Emmanuel Thierry

--=20
Romain KUNTZ
IP flavors | http://www.ipflavors.com
+33 (0)6 61 29 50 52
r.kuntz@ipflavors.com
