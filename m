From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 0/2] Tracepoint for tcp retransmission
Date: Wed, 21 Dec 2011 08:05:11 +0100
Message-ID: <1324451111.2610.13.camel@edumazet-laptop>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
	 <5f654c7d-f18e-4d70-8830-a3e31b8f5f4a@tahiti.vyatta.com>
	 <20111218004944.GB14903@hell>
	 <65795E11DBF1E645A09CEC7EAEE94B9CB5AFB01E@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59557 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab1LUHFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 02:05:30 -0500
Received: by wgbdr13 with SMTP id dr13so13758922wgb.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 23:05:29 -0800 (PST)
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFB01E@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 d=C3=A9cembre 2011 =C3=A0 18:40 -0500, Satoru Moriya a =C3=A9=
crit :

> We use trace_kfree_skb() which 63e03724b51 uses to detect packet
> drop event. In addition to that, we would like to detect errors
> in TCP layer for better trouble shooting.
>=20

If you feel we miss a counter in a particular spot, just add it, so tha=
t
even a newbie can report "netstat -s" values in a message for analysis.

Not re-sending a frame because of a temporary shortage of memory is not
an error per se, TCP will recover eventually, but keeping track of thes=
e
events might be useful (once we have not percpu counters for this, but
regular atomic counters)
