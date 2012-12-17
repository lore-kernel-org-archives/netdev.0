From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: net/usb device additions for -stable
Date: Mon, 17 Dec 2012 10:10:46 +0100
Message-ID: <87vcc1m4bt.fsf@nemi.mork.no>
References: <877gppuu5l.fsf@nemi.mork.no>
	<20121214.181241.739657750054924669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jspurohit@velocitylimitless.com,
	valdis.kletnieks@vt.edu, jan.ceuleers@computer.org,
	olof.ermis@gmail.com, tommy7765@yahoo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39469 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242Ab2LQJLF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 04:11:05 -0500
In-Reply-To: <20121214.181241.739657750054924669.davem@davemloft.net> (David
	Miller's message of "Fri, 14 Dec 2012 18:12:41 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Tue, 13 Nov 2012 21:25:58 +0100
>
>> I looked quickly through the list of added devices in the range
>> v3.6..net/master and tried to cherry-pick them into the current 3.0,
>> 3.2, 3.4 and 3.6 stable trees.  There weren't really that many. The
>> result was:
>>=20
>> # for stable-3.6:
>> af1b85e usb/ipheth: Add iPhone 5 support
>> c6846ee net: qmi_wwan: adding more ZTE devices
>> bbc8d92 net: cdc_ncm: add Huawei devices
>>=20
>> # for stable-3.4:
>> af1b85e usb/ipheth: Add iPhone 5 support
>>=20
>> # for stable-3.2:
>> af1b85e usb/ipheth: Add iPhone 5 support
>>=20
>> # for stable-3.0:
>> af1b85e usb/ipheth: Add iPhone 5 support
>
> The iPhone 5 change applied cleanly in all cases so I added that one.
> The others did not.

Sorry about that. They did in when I tested them, but the conditions
must have been different.=20

> Could you respin them for me and I'll queue them up for the next batc=
h
> I send out?

I don't think there is much point anymore, as Greg has announced the
last 3.6 stable: https://lkml.org/lkml/2012/12/14/441

I'll come back with a set for 3.7 stable when there is something to add
instead.


Thanks,
Bj=C3=B8rn
