From: Ethan Tuttle <ethan@ethantuttle.com>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Wed, 4 Sep 2013 23:52:48 -0700
Message-ID: <CACzLR4s_aR--g-wGWHvJnoOdkLvjLm6fdcpMT6ARxS8D4-g6wQ@mail.gmail.com>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130904163245.GI20552@1wt.eu>
	<CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
	<20130905051223.GB26000@1wt.eu>
	<CACzLR4uCQhGzgABV2nMG45EQBNsrW8=j5X7x-=eTSUmSvthLxg@mail.gmail.com>
	<ca521df880b08225cb34214e3ef0fc2c@cheny.fr>
	<20130905064036.GC26000@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ch=E9ny_Yves=2DGael?= <yves@cheny.fr>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:60073 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483Ab3IEGwt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 02:52:49 -0400
Received: by mail-ob0-f170.google.com with SMTP id eh20so1558350obb.29
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 23:52:48 -0700 (PDT)
In-Reply-To: <20130905064036.GC26000@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Works like a charm!  Thanks for sharing these.

It may be a while until an alternative to Marvell's uboot is available
for the Mirabox, so it's a shame these patches won't be making it into
the mainline kernel.

Regards,

Ethan

On Wed, Sep 4, 2013 at 11:40 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Sep 05, 2013 at 08:23:12AM +0200, yves@cheny.fr wrote:
>> Hi Willy,
>> i would be interested too !
>>
>> thx
>> Yves
>>
>> Le 2013-09-05 07:22, Ethan Tuttle a =E9crit :
>> >Understood.  Ultimately, I'll use this board as a router, and stabl=
e
>> >mac addresses would be better than random.  So I would be intereste=
d
>> >to try your atag -> device tree patches.  Have they been posted
>> >somewhere I can find them?
>
> OK guys, here they come. Note that they're now simplified since the
> eth* aliases have been added to the dts.
>
> Willy
>
