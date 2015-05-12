From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] tcp: tcp_info extensions
Date: Tue, 12 May 2015 13:31:53 -0700
Message-ID: <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	 <20150512130855.GA29412@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34564 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbbELUb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 16:31:56 -0400
Received: by iget9 with SMTP id t9so102973415ige.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 13:31:55 -0700 (PDT)
In-Reply-To: <20150512130855.GA29412@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 10:08 -0300, Marcelo Ricardo Leitner wrote:
> On Tue, Apr 28, 2015 at 03:28:16PM -0700, Eric Dumazet wrote:
> > As discussed during Chris Rapier presentation in Ottawa / netdev0.1,
> > we add to tcp_info the first two fields are highly wanted.
> > 
> > Each field is added into a single patch for easy code review.
> > 
> > (Corresponding iproute2/ss patches will be sent)
> > 
> > Next fields will follow once consensus is reached.
> 
> Is tcpEStatsPerfSegsOut amongst them? I have a need for this one and can
> submit a patch if you're not tracking it already.

Yes, along with tcpEStatsPerfSegsIn

Because tcp_info is aligned to 64bits, we cannot cook a patch simply
adding tcpEStatsPerfSegsOut (u32), otherwise we would introduce a hole.

If you can cook the patch adding tcpEStatsPerfSegsOut and
tcpEStatsPerfSegsIn, I would be very happy to review it.

Thanks !
