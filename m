From: Bob Copeland <me@bobcopeland.com>
Subject: Re: kerneloops.org report for the week of June 14 2009
Date: Sun, 28 Jun 2009 05:11:54 -0400
Message-ID: <b6c5339f0906280211n21287f68p6455890fd860c44@mail.gmail.com>
References: <20090614173331.18f01123@infradead.org>
	 <b6c5339f0906181008v1cd4b06aof866ea9a91d2eb84@mail.gmail.com>
	 <20090618223238.4d6b6707@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, tglx@tglx.de, alan@lxorguk.ukuu.org.uk,
	rjw@sisk.pl, netdev@vger.kernel.org, mingo@elte.hu,
	dwmw2@infradead.org, alsa-devel@alsa-project.org,
	dri-devel@lists.sourceforge.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754806AbZF1JMG@vger.kernel.org>
In-Reply-To: <20090618223238.4d6b6707@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2009 at 1:32 AM, Arjan van de Ven<arjan@infradead.org> =
wrote:
> On Thu, 18 Jun 2009 13:08:39 -0400
> Bob Copeland <me@bobcopeland.com> wrote:
>> > Rank 9: minstrel_get_rate (warning)
>>
>> I believe this is fixed by http://lkml.org/lkml/2009/6/5/269, now
>> in pre-2.6.31. =A0Hmm, odd though, we should be seeing reports from
>> other wireless drivers since it's a general memory corruption
>> unrelated to ath5k (but not all use the mac80211 rate controllers).
>
> well.. out of the 534 reports or so that I have by now... 525 have
> ath5k loaded.....
>
> it's not 100% but it'd pretty close.

Indeed, I can replicate this now, looks like some kind of race conditio=
n
since it's looking for a rate in the 5 ghz band while I'm communicating
with a 2 ghz AP (during a scan perhaps?).  The warning is harmless but
there is some underlying issue to be fixed.

--=20
Bob Copeland %% www.bobcopeland.com
