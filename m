From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 11:11:46 -0800
Message-ID: <52812BF2.7090605@candelatech.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL> <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com> <21120.29720.673157.151074@gargle.gargle.HOWL> <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com> <21120.37647.979237.40802@gargle.gargle.HOWL> <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com> <21121.575.539384.948990@gargle.gargle.HOWL> <52810800.9020402@openwrt.org> <1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com> <CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com> <CAA93jw7ciONyyUKNei5COVTA51tFWVBD4LQMp60wwxGGD=VBEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Sujith Manoharan <sujith@msujith.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Avery Pennarun <apenwarr@google.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50477 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab3KKTL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:11:56 -0500
In-Reply-To: <CAA93jw7ciONyyUKNei5COVTA51tFWVBD4LQMp60wwxGGD=VBEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2013 10:31 AM, Dave Taht wrote:
> Ah, this thread started with a huge regression in ath10k performance
> with the new TSQ stuff, and isn't actually about a two line fix to the
> mv ethernet driver.
> 
> http://comments.gmane.org/gmane.linux.network/290269
> 
> I suddenly care a lot more. And I'll care a lot, lot, lot more, if
> someone can post a rrul test for before and after the new fq scheduler
> and tsq change on this driver on this hardware... What, if anything,
> in terms of improvements or regressions, happened to multi-stream
> throughput and latency?
> 
> https://github.com/tohojo/netperf-wrapper

Not directly related, but we have run some automated tests against
an older buffer-bloat enabled AP (not ath10k hardware, don't know the
exact details at the moment), and in general the performance
is horrible compared to all of the other APs we test against.

Our tests are concerned mostly with throughput.

For reference, here are some graphs with supplicant/hostapd
running on higher-end x86-64 hardware and ath9k:

http://www.candelatech.com/lf_wifi_examples.php

We see somewhat similar results with most commercial APs, though
often they max out at 128 or fewer stations instead of the several
hundred we get on our own AP configs.

We'll update to more recent buffer-bloat AP software and post some
results when we get a chance.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
