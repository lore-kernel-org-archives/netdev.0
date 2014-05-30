From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net-next 3/8] net: cdc_ncm: inform usbnet when rx buffers are reduced
Date: Fri, 30 May 2014 15:39:14 +0200
Message-ID: <87mwdz8jy5.fsf@nemi.mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
	<1401435070-26721-4-git-send-email-bjorn@mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D1725057A@AcuExch.aculab.com>
	<87d2eva41t.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D17250700@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56078 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbaE3Nja convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 09:39:30 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17250700@AcuExch.aculab.com>
	(David Laight's message of "Fri, 30 May 2014 12:42:29 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> From: Bj=C3=B8rn Mork
> ...
>> > Since you are now copying the data out of the URB's skb before
>> > passing the ethernet packet upstream, is there ever any real
>> > requirement to use a small rx_max? or ever change rx_max?
>>=20
>> Yes.  usbnet doesn't currently recycle skbs.  Continuously allocatin=
g 32
>> kB skbs (or even 64 kB truesize, which is the current cdc_ncm worst
>> case) on memory constrained hosts is bound to fail eventually.
>
> Getting usbnet to recycle skb shouldn't be too hard - and will
> be an immediate gain for most of the drivers.

Yes.  This is one of those problems that really isn't that hard to
solve.  Until you start hitting all the corner cases...  But I'm sure i=
t
is doable.

Anyway, it is not going to be part of this patch series, which is merel=
y
touching the cdc_ncm minidriver within the existing usbnet framework.


Bj=C3=B8rn
