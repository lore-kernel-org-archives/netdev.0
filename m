From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] udp: Add udp early demux
Date: Fri, 04 Oct 2013 14:16:38 -0700
Message-ID: <1380921398.3564.42.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
	 <1380914896-24754-3-git-send-email-shawn.bohrer@gmail.com>
	 <1380916926.3564.30.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131004210511.GA12356@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:65454 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3JDVQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 17:16:45 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so4616237pad.7
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 14:16:45 -0700 (PDT)
In-Reply-To: <20131004210511.GA12356@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 16:05 -0500, Shawn Bohrer wrote:

> Same thing must be true in the multicast case correct? I'll fix them
> both.

Yes.

And you could state in the title or changelog that you took care of IPv4
only (which is fine, but worth mentioning)

Also, unicast lookup should use the secondary hash on (local port, local
address) for best hash distribution for this particular lookup for a
connected socket.

(Take a look at commits 5051ebd27 and  512615b6b84 for details)
