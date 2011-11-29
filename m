From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 17:06:05 +0100
Message-ID: <CAA93jw5UG4=QRN3Wnh82wRg8YCSV7vDqGp0HyeVxsihUwLuioQ@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	<CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	<1322550138.2970.70.camel@edumazet-laptop>
	<1322576645.7454.48.camel@deadeye>
	<1322576986.2465.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38776 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116Ab1K2QGG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:06:06 -0500
Received: by qadc14 with SMTP id c14so2133704qad.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 08:06:06 -0800 (PST)
In-Reply-To: <1322576986.2465.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 3:29 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 29 novembre 2011 =E0 14:24 +0000, Ben Hutchings a =E9crit :
>
>> Not if you separate hardware queues by priority (and your high prior=
ity
>> packets are non-TCP or PuSHed).
>
> I mostly have tg3 , bnx2 cards, mono queues...
>
> I presume Dave, working on small Wifi/ADSL routers have same kind of
> hardware.

Nothing but mono queues here on wired - 4 queues on wireless, however.

and a focus on trying to make sure the
10Gig guys don't swamp the 128Kbit to 100Mbit guys, and everything in
between that bandwidth range is what I care about, mostly against GigE
servers...

( I'm still waiting on some 10Gig hw donations to arrive)

However the hardware array is much larger than you presume.

We have a variety of hardware, ranging from 7 cerowrt routers located
in the bloatlab #1 at ISC.org,  where there are also a couple x86_64
based multicore servers, and a variety of related (mostly wireless)
hardware, such as a bunch of OLPCs.

Bloatlab #1 is in California, and connected to the internet via 10gige
and on a dedicated gigE connection all it's own.

http://www.bufferbloat.net/projects/cerowrt/wiki/BloatLab_1

With overly reduced TX rings to combat bufferbloat, the best the
routers in the lab can do is about 290Mbit. They have excellent TCP_RR
stats, though. With larger rings, they do 540Mbit+. It's my hope with
BQL on the router to get closer to the larger figure.

One of the x86 machines in the lab does TSO and it's ugly...

I'm now based in Paris specifically to be testing FQ and AQM solutions
over the 170 ms LFN between here and there and have been working on
QFQ + RED (while awaiting 'RED light' both at 100Mbit line rates and
at software simulated rates below that common to actual end user
connectivity to the internet.

http://www.bufferbloat.net/issues/312

I have 3 additional routers and  several e1000e machines here in Paris.

And I'm checking into the interactions of all this against everything
else against a variety of models. ISC has made the bloatlab is
available to all, I note, if anyone wants to run a test there, let me
know....


>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
