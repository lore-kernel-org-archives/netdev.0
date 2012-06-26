From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 10:46:48 +0200
Message-ID: <1340700408.10893.275.camel@edumazet-glaptop>
References: <1340696398.10893.209.camel@edumazet-glaptop>
	 <20120626.004658.2123525722448546355.davem@davemloft.net>
	 <1340698984.10893.248.camel@edumazet-glaptop>
	 <20120626.013730.902797211256084220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53585 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab2FZIqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:46:53 -0400
Received: by eaak11 with SMTP id k11so1497606eaa.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 01:46:52 -0700 (PDT)
In-Reply-To: <20120626.013730.902797211256084220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 01:37 -0700, David Miller wrote:

> And think, we don't do any stupidity like this for the inetpeer cache
> and no small cute animals have died as a result.

Thats because inetpeer is kept small.

We do have a smart gc on inetpeer cache (inet_peer_gc()),
and inetpeer threshold is 65536 
