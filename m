From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 19:49:57 +0200
Message-ID: <1342720197.2626.4624.camel@edumazet-glaptop>
References: <1342719243.2626.4571.camel@edumazet-glaptop>
	 <20120719.103618.2037668049773125073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:52516 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab2GSRuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:50:03 -0400
Received: by vbbff1 with SMTP id ff1so2182987vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:50:02 -0700 (PDT)
In-Reply-To: <20120719.103618.2037668049773125073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 10:36 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 19 Jul 2012 19:34:03 +0200
> 
> > v2 : move unicast_sock out of ip_send_unicast_reply() body
> >      init sk_refcnt to 1, in case some driver get/put a reference on
> >      socket.
> 
> The compiler seems much happier with this, applied, thanks Eric :-)

Maybe I should install your compiler ;) What is the version you
currently use ?
