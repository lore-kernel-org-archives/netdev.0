From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 11:02:31 +0200
Message-ID: <200903111102.31599.remi.denis-courmont@nokia.com>
References: <20090309112521.GB37984@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Marian =?utf-8?q?=C4=8Eurkovi=C4=8D?= <md@bts.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:39704 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbZCKJCe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 05:02:34 -0400
In-Reply-To: <20090309112521.GB37984@bts.sk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 March 2009 13:25:21 ext Marian =C4=8Eurkovi=C4=8D wrote:
>   The behaviour could be descibed as "spiraling death" syndrome. Whil=
e
> TCP with constant and decently sized rx window natively reduces
> transmission rate when RTT increases, autotuning performs exactly the
> opposite - as a response to increased RTT it increases the rx window =
size
> (which in turn again increases RTT...) As this happens again and agai=
n, the
> result is complete waste of all available buffers at sending host or =
at the
> bottleneck point, resulting in upto 267 msec (!) latency in LAN conte=
xt
> (with 100 Mbps ethernet connection, default txqueuelen=3D1000, MTU=3D=
1500 and
> sky2 driver). Needles to say that this means the LAN is almost unusab=
le.

This is very likely a stupid question, but anyway...

Is this with all applications, or only some pathological ones (one of w=
hich we=20
both wrote code for, alright) with abnormally large send buffers?

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

