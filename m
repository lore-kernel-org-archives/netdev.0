From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Mon, 15 Aug 2011 17:27:12 +0100
Message-ID: <CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
	<20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
	<20110712113643.GC616804@jupiter.n2.diac24.net>
	<CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
	<20110715160357.GC1407585@jupiter.n2.diac24.net>
	<20110715163345.GD1407585@jupiter.n2.diac24.net>
	<20110727111714.GA2027462@jupiter.n2.diac24.net>
	<20110728084106.22166324@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:63353 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab1HOQ1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 12:27:13 -0400
Received: by pzk37 with SMTP id 37so3142416pzk.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 09:27:13 -0700 (PDT)
In-Reply-To: <20110728084106.22166324@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 July 2011 16:41, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Wed, 27 Jul 2011 13:17:15 +0200
> David Lamparter <equinox@diac24.net> wrote:
>
>> On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wrote:
>> > On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter wrote:
>> > > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
>> > > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
>> > > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
>> > > > >> I am still undecided on this. Understand the need, but don't like idea
>> > > > >> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
>> > > > >> has any input.
>> > > > >
>> > > > > The patch doesn't make the bridge behave nonconformant. The default mask
>> > > > > is 0, which just keeps the old behaviour.
>> >
>> > P.S.: I'd like to once more stress this. In my opinion the patch should
>> > be merged because it provides desireable functionality at a small cost
>> > (one test, one knob) and __does not change any default behaviour__.
>>
>> Stephen, anything new on this?
>
> No.
> Don't like adding yet another hack user visible API which will have
> to be maintained for too long. But on the other hand I don't have
> a better solution at my finger tips. If better idea doesn't come
> along, then we can go with yours.
>
I have not noticed any other proposals and this thread has been open
for quite a while.  Have we waited long enough ? If so can this patch
be taken ?

Thanks,
Nick
