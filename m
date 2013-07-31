From: Joe Perches <joe@perches.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Tue, 30 Jul 2013 20:35:02 -0700
Message-ID: <1375241702.2075.140.camel@joe-AO722>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
	 <1375241072.10515.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53178 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752658Ab3GaDfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 23:35:04 -0400
In-Reply-To: <1375241072.10515.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 20:24 -0700, Eric Dumazet wrote:
> On Wed, 2013-07-31 at 11:13 +0800, Cong Wang wrote:
> > On Tue, 2013-07-30 at 20:08 -0700, Eric Dumazet wrote:
> > > Oh well, this patch is pure noise...
> > Mind to be specific?
> > 
> > I know saving 8 bytes is not interesting for you, but it is for me,
> > since I need some room in struct tcp_metrics_block for union inet_addr.
> > With this patch, I don't have to make struct tcp_metrics_block expand to
> > 3 cachelines. :)
> 
> Do you see how this explanation is rather different than the one you
> gave in the changelog ?

Eric, do you see how your own original reply was unwarranted?

> And it would be more logical to put the "unsigned long last_syn_loss" at
> the beginning of the structure, instead after an array of 17 bytes.

True, using "unsigned long" instead of "long unsigned int"
would likely be better too.
