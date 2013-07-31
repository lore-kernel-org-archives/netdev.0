From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Wed, 31 Jul 2013 11:37:08 +0800
Message-ID: <1375241828.22980.6.camel@cr0>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
	 <1375241072.10515.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab3GaDhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 23:37:18 -0400
In-Reply-To: <1375241072.10515.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 20:24 -0700, Eric Dumazet wrote:
> On Wed, 2013-07-31 at 11:13 +0800, Cong Wang wrote:
> > On Tue, 2013-07-30 at 20:08 -0700, Eric Dumazet wrote:
> > > 
> > > Oh well, this patch is pure noise...
> > > 
> > > 
> > 
> > Mind to be specific?
> > 
> > I know saving 8 bytes is not interesting for you, but it is for me,
> > since I need some room in struct tcp_metrics_block for union inet_addr.
> > With this patch, I don't have to make struct tcp_metrics_block expand to
> > 3 cachelines. :)
> 
> Do you see how this explanation is rather different than the one you
> gave in the changelog ?
> 
> Its 3 lines, instead of all this pahole noise.

So, you mean this patch only makes sense after my union inet_addr? If
so, I will merge it into my inet_addr patch.

> 
> And it would be more logical to put the "unsigned long last_syn_loss" at
> the beginning of the structure, instead after an array of 17 bytes.
> 

Agreed.

Thanks!
