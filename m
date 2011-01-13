From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] phonet: some signedness bugs
Date: Thu, 13 Jan 2011 12:30:02 -0800 (PST)
Message-ID: <20110113.123002.46348652.davem@davemloft.net>
References: <20110110140658.GB2721@bicker>
	<20110110.160620.133889003.davem@davemloft.net>
	<201101131432.58059.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, dan.j.rosenberg@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756915Ab1AMU33 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 15:29:29 -0500
In-Reply-To: <201101131432.58059.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Thu, 13 Jan 2011 14:32:57 +0200

> On Tuesday 11 January 2011 02:06:20 ext David Miller, you wrote:
>> From: Dan Carpenter <error27@gmail.com>
>> Date: Mon, 10 Jan 2011 17:06:58 +0300
>>=20
>> > Dan Rosenberg pointed out that there were some signed comparison b=
ugs
>> > in the phonet protocol.
>> >=20
>> > http://marc.info/?l=3Dfull-disclosure&m=3D129424528425330&w=3D2
>> >=20
>> > The problem is that we check for array overflows but "protocol" is
>> > signed and we don't check for array underflows.  If you have alrea=
dy
>> > have CAP_SYS_ADMIN then you could use the bugs to get root, or som=
eone
>> > could cause an oops by mistake.
>> >=20
>> > Signed-off-by: Dan Carpenter <error27@gmail.com>
>>=20
>> Applied.
>=20
> Shouldn't this be sent to stable trees?

It will be.
