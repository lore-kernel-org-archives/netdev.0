From: David Miller <davem@davemloft.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 04:35:34 -0700 (PDT)
Message-ID: <20090617.043534.259824726.davem@davemloft.net>
References: <20090617092152.GA17449@elte.hu>
	<4A38C2F3.3000009@gmail.com>
	<20090617110803.GA10175@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tglx@linutronix.de,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751850AbZFQLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:35:31 -0400
In-Reply-To: <20090617110803.GA10175@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 17 Jun 2009 13:08:03 +0200

> 
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in __nf_conntrack_confirm()),
>> we probably want to add a synchronisation under ct->lock as well,
>> or __nf_ct_refresh_acct() could set ct->timeout.expires to extra_jiffies,
>> while a different cpu could confirm the conntrack.
>> 
>> Following patch as RFC
> 
> A quick test suggests that it seems to works here - thanks Eric!

Patrick, please take a quick look at Eric's fix.  I'd like to
apply it quickly if it looks good to you.

Thanks!
