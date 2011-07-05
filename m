From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 09:18:55 +0400
Message-ID: <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
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
	<CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
	<CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
	<1309837443.2720.8.camel@edumazet-laptop>
	<CAB9v_DFYGyYiXGfMCXn_WDeGTKz8BZPYBCuaDj_a+5VAG3Jn=g@mail.gmail.com>
	<1309839068.2720.15.camel@edumazet-laptop>
	<1309839258.2720.17.camel@edumazet-laptop>
	<CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
	<1309839928.2720.23.camel@edumazet-laptop>
	<CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	<1309840708.2720.31.camel@edumazet-laptop>
	<CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	<1309842642.2720.36.camel@edumazet-laptop>
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
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39541 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab1GEFS4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 01:18:56 -0400
Received: by vws1 with SMTP id 1so3961745vws.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 22:18:55 -0700 (PDT)
In-Reply-To: <1309842642.2720.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 09:10, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mardi 05 juillet 2011 =C3=A0 08:57 +0400, Alexey Zaytsev a =C3=A9c=
rit :
>
>> Ran tcpdump. You are right, I was wrong. Sorry for the noise.
>
> Thanks for testing ;)
>
> It would be nice to know if the memory scribbles start after or befor=
e
> one RFO triggers.
>
> I can see this calls b44_init_rings() without really stopping the dev=
ice
> before. This seems very suspect to me.
>

Actually, I've added a trace to show b44_init_rings and b44_free_rings
calls, and they are only called once, right after the driver is
loaded. So it can't be related to START_RFO. Will attach the diff and
dmesg.
