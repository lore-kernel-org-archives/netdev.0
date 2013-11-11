From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 23:59:37 +0530
Message-ID: <21121.8721.391128.979811@gargle.gargle.HOWL>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<21121.575.539384.948990@gargle.gargle.HOWL>
	<52810800.9020402@openwrt.org>
	<1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:60072 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab3KKSeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:34:07 -0500
In-Reply-To: <CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Taht wrote:
> Personally I don't have much of a problem if TSQ hurts single stream
> TCP throughput on wifi. I would vastly prefer aggregation to work
> better for multiple streams with vastly smaller buffers than it does.
> That would be a bigger win, overall.

ath9k doesn't hold very deep queues for aggregated traffic. A maximum
of 128 packets can be buffered for each Access Class queue and still
good throughput is obtained, even for 3x3 scenarios.

A loss of almost 50% throughput is seen in 1x1 setups and the penalty
becomes higher with more streams. I don't think such a big loss
in performance is acceptable to achieve low latency.

Sujith
