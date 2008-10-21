From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Tue, 21 Oct 2008 10:09:23 +0000
Message-ID: <20081021100923.GD4715@ff.dom.local>
References: <20081021090002.21e64151@topolino> <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19785 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbYJUKJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 06:09:35 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1129731nfc.21
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 03:09:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 12:36:33PM +0300, Ilpo J=E4rvinen wrote:
=2E..
> Can you try this another debug patch below (on 2.6.27.2 is fine). It =
moves=20
> the mss to the last position but should keep timestamps in place by m=
aking=20
> wscale as first option. It is well possible that you won't get it wor=
king=20
> at all except with all ts,sack and wscale set to 0 (the most likely=20
> result). Please try with all wscale,sack,ts combinations (no need to=20
> provide dumps, just working/not working per case)... This should=20
> tell us for quite high certaintity what is the actual option which is=
=20
> causing this (would it not be the mss-at-beginning which is the most=20
> likely cause), [...]

I'd like to remind it seems to work with only sack off, so mss after
ts. If so, my suspicion would be around rfc's/options' dating?

Jarek P.
