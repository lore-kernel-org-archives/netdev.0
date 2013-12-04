From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 17:18:09 -0800
Message-ID: <1386119889.30495.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529DF340.70602@mellanox.com>
	 <1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com>
	 <alpine.LFD.2.03.1312031310140.23893@intel.com>
	 <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <alpine.LFD.2.03.1312031500020.570@intel.com>
	 <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
	 <alpine.LFD.2.03.1312031626400.7539@intel.com>
	 <CAMEtUuzBpiZEzSxK7315dpJWT6LVb09hFNABUktq_0HMu9bhcQ@mail.gmail.com>
	 <alpine.LFD.2.03.1312031725150.7539@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:35195 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129Ab3LDBSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 20:18:13 -0500
Received: by mail-yh0-f53.google.com with SMTP id b20so10663965yha.26
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 17:18:12 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312031725150.7539@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 17:29 -0800, Joseph Gasparakis wrote:
> 

> Then would the fix be as simple as just unsetting the bit in vxlan? 
> Because I am guessing that there is a bug somewhere where the combination of 
> GSO_UDP_TUNNEL and GSO_DODGY. That would solve my problem, hopefully Or's 
> too if it is the same.

Not really ;)

We need to handle this bit properly, not pretending it is of no use ;)
