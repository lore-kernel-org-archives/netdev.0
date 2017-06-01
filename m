From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 11:57:15 -0700
Message-ID: <20170601115715.1107113c@cakuba.lan>
References: <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
        <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
        <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
        <20170601.143336.2263901633118099409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, dsahern@gmail.com, kafai@fb.com,
        hannes@stressinduktion.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:38641 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751105AbdFAS5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 14:57:24 -0400
In-Reply-To: <20170601.143336.2263901633118099409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Jun 2017 14:33:36 -0400 (EDT), David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Thu, 1 Jun 2017 11:27:56 -0700
> 
> > Original instructions are not useful for debugging, since they have
> > map_fds which can be long gone when program is running, therefore to
> > solve introspection problem we need to look into real kernel
> > instructions.  
> 
> The only possible legitimate use I see for the original instructions
> is checkpoint/restart.
> 
> If 6wind wants this for "external acceleration" or whatever, like
> Alexei I am not interested in facilitating that at all.

+1 

I will try disabling the inlining then.
