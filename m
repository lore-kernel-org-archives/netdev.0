From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH] i40e{,vf}: Fix out-of-bound cpumask read in IRQ
 affinity handler
Date: Thu, 17 Aug 2017 03:13:27 +0200
Message-ID: <20170817031327.16eede3c@elisabeth>
References: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
        <1502929524.32783.3.camel@intel.com>
        <20170817030109.31580d73@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        "David S . Miller" <davem@davemloft.net>,
        Alan Brady <alan.brady@intel.com>,
        Stefan Assmann <sassmann@redhat.com>,
        Juergen Gross <jgross@suse.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38586 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbdHQBNf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 21:13:35 -0400
In-Reply-To: <20170817030109.31580d73@elisabeth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 03:01:09 +0200
Stefano Brivio <sbrivio@redhat.com> wrote:

> Before posting, however, I checked patchwork at:
> 
> 	https://patchwork.ozlabs.org/project/intel-wired-lan/list/
> 
> and also your git tree (listed in MAINTAINERS) at:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue.git
> 
> but I couldn't find that commit. I also can't find it now. So I suppose
> I'm looking for it in the wrong place. Can you please tell me which
> tree or patchwork I should check before submitting patches for i40e, so
> that I avoid further duplicate submissions next time?

Okay, I just found your e-mail on netdev (I wasn't expecting to see
this queued up for net-next). IMHO, this should be queued for -net (and
-stable) instead (and my previous comments still apply).
