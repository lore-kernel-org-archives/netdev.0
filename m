From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Thu, 19 Jun 2014 07:05:23 -0700
Message-ID: <1403186723.1225.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com>
	 <53A062A9.70806@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
	 <53A071A2.20909@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725E88C@AcuExch.aculab.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725EB40@AcuExch.aculab.com>
	 <53A2E53A.3030302@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725F13F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:42198 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbaFSOF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 10:05:27 -0400
Received: by mail-we0-f181.google.com with SMTP id q59so2376710wes.40
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 07:05:25 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725F13F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-19 at 13:45 +0000, David Laight wrote:

> I noticed that the TCP code is documented to eventually send data after 200ms.
> It would be better if that interval were settable per-socket.
> I'd set it to 1ms (or next tick).

This 200ms is really RTO. We do not use an extra timer for this yet.
