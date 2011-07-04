From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 00:25:09 +0400
Message-ID: <CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
	<CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	<20110704130531.37cf876e@Nokia-N900>
	<1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110704162726.4072e715@maggie>
	<20110704164351.338dc12e@maggie>
	<1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44689 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab1GDUZK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 16:25:10 -0400
Received: by vws1 with SMTP id 1so3802565vws.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 13:25:09 -0700 (PDT)
In-Reply-To: <1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2011 at 19:12, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le lundi 04 juillet 2011 =C3=A0 16:43 +0200, Michael B=C3=BCsch a =C3=
=A9crit :
>> On Mon, 4 Jul 2011 16:27:26 +0200
>> Michael B=C3=BCsch <m@bues.ch> wrote:
>> > We do this in b43, which has exactly the same DMA engine.
>>
>> (Ok, it turns out we don't do this in b43 (We only do it on the TX s=
ide).
>> =C2=A0But that's a bug. We should do a wmb() on the RX side before a=
dvancing the
>> =C2=A0descriptor ring pointer.)
>
> I am wondering what happens if RX ring is set to 64, and we receive
> exactly 64 buffers in one round, B44_DMARX_PTR wont change at all ?
>
> Alexey, could you try this patch please ?

Sorry, did not help.
