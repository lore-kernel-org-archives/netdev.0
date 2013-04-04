From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Thu, 04 Apr 2013 08:44:47 -0700
Message-ID: <1365090287.3308.3.camel@edumazet-glaptop>
References: <1364917500.5113.176.camel@edumazet-glaptop>
	 <20130402155822.GB29115@redhat.com>
	 <20130402.121223.496337697838525487.davem@davemloft.net>
	 <1364920077.5113.185.camel@edumazet-glaptop>
	 <20130404153530.GA1688@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38721 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759987Ab3DDPow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 11:44:52 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so1506239pbc.17
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 08:44:51 -0700 (PDT)
In-Reply-To: <20130404153530.GA1688@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 17:35 +0200, Jiri Pirko wrote:

> It can be converted now to call_rcu. synchronize_rcu is making sure
> no packet is in flight when changing modes.

What changes exactly ? You don't really answer to my question with this
very vague sentence.

Because maybe the synchronize_net() in netdev_rx_handler_unregister()
is enough and you dont even need the call_rcu(). Thats was my question.

RCU barriers are not magical things we add when we are not exactly sure
of what is happening.

Like other barriers (wmb(), smb_wmb(), ...) we should document or
understand why they are needed.
