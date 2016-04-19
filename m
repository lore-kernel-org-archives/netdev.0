From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 11:06:46 -0700
Message-ID: <1461089206.10638.226.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <5716347D.3030808@solarflare.com>
	 <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
	 <571661E5.7010304@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35241 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbcDSSGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:06:46 -0400
Received: by mail-pa0-f47.google.com with SMTP id fs9so8965805pac.2
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 11:06:46 -0700 (PDT)
In-Reply-To: <571661E5.7010304@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 17:50 +0100, Edward Cree wrote:
> On 19/04/16 15:50, Eric Dumazet wrote:
> > The main problem in UDP stack today is having to lock the socket because
> > of the dumb forward allocation problem.
> I'm not quite sure what you're referring to here, care to educate me?


This was added for memory accounting, commit
95766fff6b9a78d11fc2d3812dd035381690b55d

TCP stack does not reclaim its forward allocations as aggressively.
(It has a concept of 'memory pressure')
