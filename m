From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Tue, 22 Apr 2014 22:13:00 -0700
Message-ID: <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	 <20140422.235745.1219194947074686642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37535 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbaDWFNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 01:13:02 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so386538pab.11
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 22:13:01 -0700 (PDT)
In-Reply-To: <20140422.235745.1219194947074686642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 23:57 -0400, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 22 Apr 2014 20:18:57 -0700
> 
> > exisiting BPF verifier allows uninitialized access to registers,
> > 'ret A' is considered to be a valid filter.
> > So initialize A and X to zero to prevent leaking kernel memory
> > In the future BPF verifier will be rejecting such filters
> > 
> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Has the code always been like this?
> 
> Did the eBPF changes introduce this problem either directly or
> indirectly?

Original code was fine AFAIK

Fixes: bd4cf0ed331a2 ("net: filter: rework/optimize internal BPF interpreter's instruction set")

David, is it possible for you to push net-next tree ?

Thank !
