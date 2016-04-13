From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP reaching to maximum throughput after a long time
Date: Tue, 12 Apr 2016 20:32:29 -0700
Message-ID: <1460518349.32504.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
	 <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570D0E94.3080006@candelatech.com>
	 <AE1C82FB3D0EC64DB1F752C81CBD110139101889@DFRE01.ent.ti.com>
	 <570D566B.8050302@candelatech.com>
	 <1460492253.6473.596.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570D5944.5070100@candelatech.com>
	 <1460492999.6473.599.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570D6B39.3050605@candelatech.com>
	 <CAK6E8=f+4BagGi5BzLER=Hn2dDJ5FHWkEqLq=04tnWResk58GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"Machani, Yaniv" <yanivma@ti.com>, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33552 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965151AbcDMDcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 23:32:32 -0400
In-Reply-To: <CAK6E8=f+4BagGi5BzLER=Hn2dDJ5FHWkEqLq=04tnWResk58GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-12 at 20:08 -0700, Yuchung Cheng wrote:

> based on the prev thread I propose we disable hystart ack-train. It is
> brittle under various circumstances. We've disabled that at Google for
> years.

Right, but because we also use sch_fq packet scheduler and pacing ;)
