From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 17:05:05 +0000
Message-ID: <BL2PR07MB23069F2EFE839087FF63AC488D7D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
        <20170115.233830.123911280062970298.davem@davemloft.net>
        <20170116092435.GA2970@mystictot>
 <20170116.114606.1692928906878877115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: "mayhs11saini@gmail.com" <mayhs11saini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0051.outbound.protection.outlook.com ([104.47.37.51]:10677
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750826AbdAPRFH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 12:05:07 -0500
In-Reply-To: <20170116.114606.1692928906878877115.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > On Sun, Jan 15, 2017 at 11:38:30PM -0500, David Miller wrote:
> >>
> >> Please do not ever submit two patches which have the same exact
> >> commit header line, as these two patches do.
> >>
> >> When someone looks into the shortlog of GIT history all they will see
> >> is "qed: Replace memset with eth_zero_addr" twice.
> >>
> >> This gives the reader no idea what might be different between those
> >> two changes.
> >>
> >> Therefore you must give unique a commit header text for each change,
> >> which communicates sufficiently what is different in each change.
> >
> > Thanks a lot for correcting me. I'll take care of this thing.
> >
> > I'm resending these two patches as
> > 	1). qed: Replace memset with eth_zero_addr
> > 	2). qed: Use eth_zero_addr
> >
> > I hope it resolves same commit header line conflict.
>=20
> You aren't understanding the point.
>=20
> Those two lines still say exactly the same thing.
>=20
> What is different about these two changes?  The answer to that question
> must propagate into those lines of text.

Other than the fact these 2 patches change 2 different qed files,
is there any significant difference between what each does?
If not, why not simply do both in a single patch?
