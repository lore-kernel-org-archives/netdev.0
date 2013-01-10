From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 10:49:17 -0800
Message-ID: <50EF0D2D.3040700@hp.com>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan> <1357750898.27446.33.camel@edumazet-glaptop> <1357751372.27446.40.camel@edumazet-glaptop> <1357801149.27446.1142.camel@edumazet-glaptop> <20130110072136.GK9943@1wt.eu> <1357831787.27446.2168.camel@edumazet-glaptop> <1357834825.27446.2205.camel@edumazet-glaptop>  <50EF06DD.7070207@hp.com> <1357843328.27446.2417.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:39589 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab3AJStY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 13:49:24 -0500
In-Reply-To: <1357843328.27446.2417.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 10:42 AM, Eric Dumazet wrote:
> Can we use zero copy for the sender as well (sendfile() or vmsplice()) ?

Not at present.  The TCP_SENDFILE test has not been "migrated" and there 
is no corresponding sendfile() test in the omni code, so the attempt to 
enable copy-avoidance won't "take."

I'll take that as a feature request for netperf.

rick
