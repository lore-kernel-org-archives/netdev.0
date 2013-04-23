From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 16:26:31 -0700
Message-ID: <1366759591.8964.42.camel@edumazet-glaptop>
References: <1366749094-5982-1-git-send-email-willemb@google.com>
	 <20130423.184140.2020239496583590253.davem@davemloft.net>
	 <1366758683.8964.37.camel@edumazet-glaptop>
	 <20130423.191540.217250507483659201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:61490 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab3DWX0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 19:26:34 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so281231pbc.2
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 16:26:33 -0700 (PDT)
In-Reply-To: <20130423.191540.217250507483659201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 19:15 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 Apr 2013 16:11:23 -0700
> 
> > I guess we should at least not include this code on !SMP builds
> 
> I think CONFIG_RPS already an appropriate guard for something like
> this.  And it depends upon SMP et al.

Yes, something like :

config NET_FLOW_LIMIT
	bool "Flow shedding under load"
	depends on RPS
	default y
