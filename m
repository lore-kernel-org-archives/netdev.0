From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Wed, 25 Sep 2013 05:44:25 -0700
Message-ID: <1380113065.3165.146.camel@edumazet-glaptop>
References: <20130925055418.GV7660@secunet.com>
	 <1380110163.3165.138.camel@edumazet-glaptop>
	 <20130925121337.GZ7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:34853 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111Ab3IYMo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 08:44:27 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so5951513pbb.24
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 05:44:27 -0700 (PDT)
In-Reply-To: <20130925121337.GZ7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 14:13 +0200, Steffen Klassert wrote:
> It was commit c544193214 (GRE: Refactor GRE tunneling code.)
> when net/ipv4/ip_tunnel.c was created.

Yeah. This one begins to be very upsetting.

> 
> > 
> > (commit id and title in your changelog would be really nice)
> > 
> 
> I can send a v2 with these informations included if you want
> that.

I think that patches coming from experimented kernel developers
should always include a study of bug origin.

Otherwise, both maintainer and stable teams have to figure it, and
they sometime lack the time or context.

Plus it's good to CC patch author and reviewers so that he can learn of
its mistakes, and Ack your work as well.

Thanks
