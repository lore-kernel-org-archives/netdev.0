From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Sat, 17 Apr 2010 11:19:23 +0200
Message-ID: <m3bpdi8mhw.fsf@ursa.amorsen.dk>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
	<4BBE4BB4.1060209@gmail.com>
	<i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>
	<20100409212657.GA3560@del.dom.local>
	<p2q298f5c051004140322hc54f5315taa5c7d85cb74f06@mail.gmail.com>
	<4BC63766.5080104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:54775 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465Ab0DQJTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Apr 2010 05:19:30 -0400
In-Reply-To: <4BC63766.5080104@gmail.com> (Jarek Poplawski's message of "Wed,
	14 Apr 2010 23:45:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> As I wrote before, the minimal (overflow safe) rate depends on max
> packet size, and for 1500 byte it would be something around:
> 1500b/2min, so if your clients can wait so long, try this:

Wouldn't it be nice of either tc or the kernel to warn about wrong
configurations, or possibly reject them completely?


/Benny

