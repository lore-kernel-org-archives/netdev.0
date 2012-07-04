From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Using interface number probing for usbnet drivers before 3.6-rc1?
Date: Wed, 04 Jul 2012 16:50:53 +0200
Message-ID: <87ipe3lgvm.fsf@nemi.mork.no>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
	<20120622.171735.637204872051168180.davem@davemloft.net>
	<87y5neidk1.fsf@nemi.mork.no>
	<20120623.023749.1066357959466872561.davem@davemloft.net>
	<87mx3flqns.fsf_-_@nemi.mork.no> <20120704144649.GC23020@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40190 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593Ab2GDOvD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 10:51:03 -0400
In-Reply-To: <20120704144649.GC23020@kroah.com> (Greg Kroah-Hartman's message
	of "Wed, 4 Jul 2012 07:46:49 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:
> On Wed, Jul 04, 2012 at 01:19:35PM +0200, Bj=C3=B8rn Mork wrote:
>> David Miller <davem@davemloft.net> writes:
>> > From: Bj=C3=B8rn Mork <bjorn@mork.no>
>> > Date: Sat, 23 Jun 2012 11:26:54 +0200
>> >
>> >> Is waiting for 3.6-rc1 the best alternative, or is cherry-picking=
 them
>> >> an option?
>> >
>> > I'm extremely reluctant to have a dependency on another tree.
>> >
>> > The USB tree, on the other hand, could pull the net-next tree
>> > in so you can continue your dependent work there.
>>=20
>> Hello Greg,
>>=20
>> I know I said I would be more careful about cross-tree dependencies,=
 but
>> here I am again...
>>=20
>> The context is: How should I proceed with interface number based pro=
bing
>> for usbnet drivers, in particular qmi_wwan which already has a few
>> patches in net-next?
>>=20
>> I see two possible remaining options:
>>=20
>>  1) you pull the net-next changes into usb-next so that I can do the
>>     work against usb-next now, or
>>  2) I wait for 3.6-rc1 and do the work against the net tree after
>>     3.6-rc1 is merged there
>>=20
>> I have decided to go for option #2 unless either of you have other
>> preferences, as I believe that is going to cause the least work and
>> merge trouble for you both.
>
> What about:
>    3) You send the usb interface number matching patches again for th=
em
>    to be included in the net-next tree as well, causing duplicates to=
 be
>    in linux-next, but allowing you to send your patches into net-next=
=2E
>
> That is what we have done at times for other patches, and if David is=
 ok
> with it, so am I.  Odds are, the merge will happen automatically, but=
 if
> not, I can handle it when 3.6-rc1 comes around.
>
> Sound good?

I could have misunderstood, but I thought that was out of the question
given that David didn't want to cherry-pick them from usb-next.


Bj=C3=B8rn=20
