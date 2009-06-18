From: Bob Copeland <me@bobcopeland.com>
Subject: Re: kerneloops.org report for the week of June 14 2009
Date: Thu, 18 Jun 2009 13:08:39 -0400
Message-ID: <b6c5339f0906181008v1cd4b06aof866ea9a91d2eb84@mail.gmail.com>
References: <20090614173331.18f01123@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, tglx@tglx.de, alan@lxorguk.ukuu.org.uk,
	rjw@sisk.pl, netdev@vger.kernel.org, mingo@elte.hu,
	dwmw2@infradead.org, alsa-devel@alsa-project.org,
	dri-devel@lists.sourceforge.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:44369 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbZFRROd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 13:14:33 -0400
In-Reply-To: <20090614173331.18f01123@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 14, 2009 at 8:33 PM, Arjan van de Ven<arjan@infradead.org> =
wrote:
> Rank 9: minstrel_get_rate (warning)
> =A0 =A0 =A0 =A0Reported 64 times (384 total reports)
> =A0 =A0 =A0 =A0Issue with the ath5k driver
> =A0 =A0 =A0 =A0This warning was last seen in version 2.6.30-rc3, and =
first seen in 2.6.27.12.
> =A0 =A0 =A0 =A0More info: http://www.kerneloops.org/searchweek.php?se=
arch=3Dminstrel_get_rate

I believe this is fixed by http://lkml.org/lkml/2009/6/5/269, now
in pre-2.6.31.  Hmm, odd though, we should be seeing reports from
other wireless drivers since it's a general memory corruption
unrelated to ath5k (but not all use the mac80211 rate controllers).

(2.6.27.12 must be a backport, minstrel didn't exist until .29)

--=20
Bob Copeland %% www.bobcopeland.com
