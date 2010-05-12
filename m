From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/9] netdev: bfin_mac: add support
 for IEEE 1588 PTP
Date: Wed, 12 May 2010 09:20:50 +0200
Message-ID: <20100512072050.GA2934@riccoc20.at.omicron.at>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
 <20100511070716.GA3254@riccoc20.at.omicron.at>
 <AANLkTikcdpIlZAE-AwahNie8KOys7jIhiNb9kiT_B7Av@mail.gmail.com>
 <AANLkTilpgUrQfFpmgHhUSCprbnTSC9LCGpFxSUEaGSWr@mail.gmail.com>
 <AANLkTimPOxc4RQ5iDMk8N9xYFb95VaqFleUa_nG4Gwwn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Barry Song <21cnbao@gmail.com>, netdev@vger.kernel.org,
	Barry Song <barry.song@analog.com>,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53467 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab0ELHUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 03:20:41 -0400
Received: by fxm4 with SMTP id 4so241503fxm.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 00:20:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTimPOxc4RQ5iDMk8N9xYFb95VaqFleUa_nG4Gwwn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 11, 2010 at 11:31:37PM -0400, Mike Frysinger wrote:
> On Tue, May 11, 2010 at 23:20, Barry Song wrote:
> >
> > I think the API can work for blackfin. =A0But our PTP driver is bas=
ed on
> > drivers/net/igb and has worked together with user-space PTPD utilit=
y.
> > Here he is writing a different driver framework. It is not the mome=
nt
> > for us to merge now. Maybe next kernel version after his patches ha=
ve
> > been popular.
>=20
> i'm not going to merge them into our tree ahead of the net->mainline
> merge.  Richard would just like some feedback on the proposed
> framework to make sure it doesnt have limitations we'd have to fix
> after things get merged.

Yes, thats right. It is enough just to know that the API *could* work
for blackfin. The idea is to have a standard API that works for all
current (and likely future) PTP hardware clocks.

The patch set is still under active development and review, so it is
better for you to wait until the dust settles.

Thanks,
Richard

