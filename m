From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 06:39:04 -0700
Message-ID: <1398260344.29914.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	  <20140422.235745.1219194947074686642.davem@davemloft.net>
	 <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5357A7EE.6040404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ast@plumgrid.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35848 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828AbaDWNjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:39:06 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so795271pbb.33
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 06:39:05 -0700 (PDT)
In-Reply-To: <5357A7EE.6040404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-23 at 13:45 +0200, Daniel Borkmann wrote:
> On 04/23/2014 07:13 AM, Eric Dumazet wrote:
> >
> > David, is it possible for you to push net-next tree ?
> 
> I think this would need to go into net tree first and then
> for the upcoming changes, net would need to be merged into
> net-next. This will create a minor merge conflict with the
> BPF prandom extension; fix is to remove the defines near
> __get_random_u32(), as they will be above __sk_run_filter()
> already.

My suggestion to push net-next was not related to the bpf patch.

I needed net-next being fresh for a backport into Google kernels.

Thanks
