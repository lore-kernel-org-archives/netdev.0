From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 06 Jan 2016 07:03:00 -0800
Message-ID: <1452092580.8255.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
	 <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCBE431@AcuExch.aculab.com>
	 <1452090307.8255.173.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCBE614@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35285 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcAFPDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 10:03:02 -0500
Received: by mail-pf0-f182.google.com with SMTP id 78so243387030pfw.2
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 07:03:02 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCBE614@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 14:49 +0000, David Laight wrote:

> Someone also pointed out that the code is memory limited (dual add
> chains making no difference), so why is it unrolled at all?

Because it matters if the data is already present in CPU caches.

So why not unrolling if it helps in some situations ?
