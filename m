From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] gre: Fix regression in gretap TSO support
Date: Thu, 30 Oct 2014 08:00:26 -0700
Message-ID: <1414681226.631.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
		<CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>
	 <CADVnQykSY_Q3HL0T1uNO4iUheWTpTsLLF7gCnM4SbJyGp3x6Wg@mail.gmail.com>
	 <54524B6A.3000503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Pravin Shelar <pshelar@nicira.com>, alexander.duyck@gmail.com,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:44677 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759876AbaJ3PA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:00:28 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so5258037pdj.24
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 08:00:28 -0700 (PDT)
In-Reply-To: <54524B6A.3000503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 07:30 -0700, Alexander Duyck wrote:

> The change is consistent with how we handle this in other spots 
> throughout the kernel.  If nothing else you can just search for 
> ETH_P_TEB and you will find multiple spots in the kernel where IP 
> tunnels differentiate between transparent Ethernet bridging and regular 
> IP in IP tunnels by checking for the protocol ETH_P_TEB.

Agreed, I think that GUE might supersedes GRE usage anyway ;)

Acked-by: Eric Dumazet <edumazet@google.com>
