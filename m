From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH v1 1/3] usb: gadget: NCM: RX function support multiple
 NDPs
Date: Fri, 30 May 2014 12:45:48 +0100
Message-ID: <53886F6C.7090509@mentor.com>
References: <jim_baxter@mentor.com>	<1401383543-10181-1-git-send-email-jim_baxter@mentor.com>	<1401383543-10181-2-git-send-email-jim_baxter@mentor.com> <87d2ewbejv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d2ewbejv.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/05/14 19:55, Bj=C3=B8rn Mork wrote:
> Jim Baxter <jim_baxter@mentor.com> writes:
>=20
>> The NDP was ignoring the wNextNdpIndex in the NDP which
>> means that NTBs containing multiple NDPs would have missed
>> frames.
>=20
> Well, just for the record: I believe this field was meant to be reser=
ved
> and always 0 in the CDC NCM spec.  Table 3-3, describing 16bit NDPs,
> says so.  But reading the spec now, I noticed that there is an
> inconsistency between table 3-3 and table 3-4 describing 32bit NDPs. =
 It
> looks like the field is not reserved in the 32bit version.
>=20
> I am pretty sure that is a specification error, but I guess it doesn'=
t
> harm to implement the support anyway.  And it paves the way for an MB=
IM
> gadget :-)
>=20
>=20
>=20
>=20
> Bj=C3=B8rn
>=20

Yes I was looking at Figure 3-1, Figure 3-2 which all state it is a
link. I must have been reading Table 3-4.

I am glad to see it helps with the MBIM specification :-) .

Jim
