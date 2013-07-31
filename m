From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Tue, 30 Jul 2013 20:24:32 -0700
Message-ID: <1375241072.10515.59.camel@edumazet-glaptop>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:64950 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab3GaDYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 23:24:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so333549pab.1
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 20:24:33 -0700 (PDT)
In-Reply-To: <1375240402.22980.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 11:13 +0800, Cong Wang wrote:
> On Tue, 2013-07-30 at 20:08 -0700, Eric Dumazet wrote:
> > 
> > Oh well, this patch is pure noise...
> > 
> > 
> 
> Mind to be specific?
> 
> I know saving 8 bytes is not interesting for you, but it is for me,
> since I need some room in struct tcp_metrics_block for union inet_addr.
> With this patch, I don't have to make struct tcp_metrics_block expand to
> 3 cachelines. :)

Do you see how this explanation is rather different than the one you
gave in the changelog ?

Its 3 lines, instead of all this pahole noise.

And it would be more logical to put the "unsigned long last_syn_loss" at
the beginning of the structure, instead after an array of 17 bytes.
