From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Wed, 31 Aug 2011 21:41:26 +0100
Message-ID: <CAEJpZP0riOx=7umYgr3fV4JF31+8Jv8m6DRTkyyuiDnioff4Vw@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
	<20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
	<20110712113643.GC616804@jupiter.n2.diac24.net>
	<CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
	<20110715160357.GC1407585@jupiter.n2.diac24.net>
	<20110715163345.GD1407585@jupiter.n2.diac24.net>
	<20110727111714.GA2027462@jupiter.n2.diac24.net>
	<20110728084106.22166324@nehalam.ftrdhcpuser.net>
	<CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
	<20110815112501.3a3c01ad@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Lamparter <equinox@diac24.net>, eswierk@bigswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44757 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab1HaUl1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:41:27 -0400
Received: by gya6 with SMTP id 6so899493gya.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 13:41:27 -0700 (PDT)
In-Reply-To: <20110815112501.3a3c01ad@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 August 2011 19:25, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Mon, 15 Aug 2011 17:27:12 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
>
>> On 28 July 2011 16:41, Stephen Hemminger
>> <shemminger@linux-foundation.org> wrote:
>> > On Wed, 27 Jul 2011 13:17:15 +0200
>> > David Lamparter <equinox@diac24.net> wrote:
>> >
>> >> On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wrote:
>> >> > On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter wrote=
:
>> >> > > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
>> >> > > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.net>=
 wrote:
>> >> > > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemming=
er wrote:
>> >> > > > >> I am still undecided on this. Understand the need, but d=
on't like idea
>> >> > > > >> of bridge behaving in non-conforming manner. Will see if=
 IEEE 802 committee
>> >> > > > >> has any input.
>> >> > > > >
>> >> > > > > The patch doesn't make the bridge behave nonconformant. T=
he default mask
>> >> > > > > is 0, which just keeps the old behaviour.
>> >> >
>> >> > P.S.: I'd like to once more stress this. In my opinion the patc=
h should
>> >> > be merged because it provides desireable functionality at a sma=
ll cost
>> >> > (one test, one knob) and __does not change any default behaviou=
r__.
>> >>
>> >> Stephen, anything new on this?
>> >
>> > No.
>> > Don't like adding yet another hack user visible API which will hav=
e
>> > to be maintained for too long. But on the other hand I don't have
>> > a better solution at my finger tips. If better idea doesn't come
>> > along, then we can go with yours.
>> >
>> I have not noticed any other proposals and this thread has been open
>> for quite a while. =A0Have we waited long enough ? If so can this pa=
tch
>> be taken ?
>>
>
> I am testing an alternative. The problem with your proposal is that
> it relies on the multicast address. It turns out there are people usi=
ng
> other addresses for the STP group address, so using that as a identif=
ier
> is incorrect.
If the chosen STP group address is in the local multicast group range
this patch will handle it.

David Lamparter has reviewed this patch and asked for it to be merged.
 This patch has at least two real world uses.  Ed needs this patch to
forward LLDP frames and I need this patch to forward 802.1X frames.

This patch has been out for review for 9 weeks and it still looks like
the best solution.

Could this patch be merged please ?

Thanks,
Nick
