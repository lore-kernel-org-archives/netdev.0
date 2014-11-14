From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] icmp: Remove some spurious dropped packet
 profile hits from the ICMP path
Date: Fri, 14 Nov 2014 08:58:49 -0800
Message-ID: <1415984329.17262.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141113225457.A3E502900805@tardy>
	 <1415931471.17262.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54662AF9.4050002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35629 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161207AbaKNQ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 11:58:55 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so3572252iec.3
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 08:58:54 -0800 (PST)
In-Reply-To: <54662AF9.4050002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 08:16 -0800, Rick Jones wrote:

> I thought the point of the drop profiling was to show where the drops 
> were happening.  Leaving the kfree_skb() up in icmp_rcv() does not 
> improve showing where the drops happened.  That is why I've pushed it 
> down into the routines called by icmp_rcv().

OK, but we drop an icmp message, and that really should be enough.

The point is that most normal icmp messages wont be dropped, but
consumed.

I am not sure we want to bloat the kernel for such minor problem.
