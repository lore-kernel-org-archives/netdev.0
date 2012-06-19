From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 06:07:26 +0200
Message-ID: <1340078846.7491.2127.camel@edumazet-glaptop>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43224 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab2FSEHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:07:31 -0400
Received: by eeit10 with SMTP id t10so1814218eei.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:07:30 -0700 (PDT)
In-Reply-To: <20120618.194016.2282814982594761206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 19:40 -0700, David Miller wrote:
> You know you want it.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Yeah, very good idea David ;)

needs some polishing of course.

This reminds the idea of having seperate dst per tcp socket, to remove
the dst refcnt contention as well.
