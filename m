From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Wed, 23 Jan 2008 15:44:54 +0800
Message-ID: <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
References: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
	 <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801221744m37021e88h5c188e5b31ea42bf@mail.gmail.com>
	 <20080122.190137.206066966.davem@davemloft.net>
	 <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.244]:19329 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbYAWHo5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:44:57 -0500
Received: by ag-out-0708.google.com with SMTP id 23so2013730agd.10
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 23:44:54 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 23, 2008 3:41 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wr=
ote:
>
> On Tue, 22 Jan 2008, David Miller wrote:
>
> > From: "Dave Young" <hidave.darkstar@gmail.com>
> > Date: Wed, 23 Jan 2008 09:44:30 +0800
> >
> > > On Jan 22, 2008 6:47 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.=
fi> wrote:
> > > > [PATCH] [TCP]: debug S+L
> > >
> > > Thanks, If there's new findings I will let you know.
> >
> > Thanks for helping with this bug Dave.
>
> I noticed btw that there thing might (is likely to) spuriously trigge=
r at
> WARN_ON(sacked !=3D tp->sacked_out); because those won't be equal whe=
n SACK
> is not enabled. If that does happen too often, I send a fixed patch f=
or
> it, yet, the fact that I print print tp->rx_opt.sack_ok allows
> identification of those cases already as it's zero when SACK is not
> enabled.
>
> Just ask if you need the updated debug patch.

Thanks,  please send, I would like to get it.

>
> --
>  i.
