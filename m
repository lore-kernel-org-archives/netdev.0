From: Saku Ytti <saku@ytti.fi>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 09:26:11 +0200
Message-ID: <20121128072611.GA26010@pob.ytti.fi>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
 <50B4F2DA.8020206@hp.com>
 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
 <20121127.210611.1127622873924794001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:49800 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab2K1H0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 02:26:17 -0500
Received: by mail-lb0-f174.google.com with SMTP id gi11so7330677lbb.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 23:26:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121127.210611.1127622873924794001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (2012-11-27 21:06 -0500), David Miller wrote:

> And the gains of fast retransmit far outweigh whatever strange
> justification would give for reordering packets on purpose.

I don't disagree. I'm not proposing to turn off fast retransmits.

My proposal (or question more accurately) was to add 'reorder' counter to
sockets, which would increment when duplicate ACK is followed by same
sequence twice. 
Then you could automatically/dynamically delay duplicate acks, as you'd
start to expect to receive the frames, out-of-order. Giving non-lossy
reordering links pretty much 100% same performance as non-lossy in-order
links.

There are good amount of optimization in TCP for corner-case, and well that
is what TCP stack does, tries to work with limitations imposed by network.

My main question is, am I underestimating complexity needed to add such
counter. Or does such counter actually already exist (I've not looked if
netstat -s reordering counters are attributable to particular socket)

-- 
  ++ytti
