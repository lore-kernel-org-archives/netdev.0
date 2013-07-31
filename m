From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Wed, 31 Jul 2013 11:40:43 +0800
Message-ID: <1375242043.22980.7.camel@cr0>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	 <1375240090.10515.53.camel@edumazet-glaptop> <1375240402.22980.5.camel@cr0>
	 <1375241072.10515.59.camel@edumazet-glaptop>
	 <1375241702.2075.140.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab3GaDkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 23:40:55 -0400
In-Reply-To: <1375241702.2075.140.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 20:35 -0700, Joe Perches wrote:
> True, using "unsigned long" instead of "long unsigned int"
> would likely be better too. 

"long unsigned int" is the output of pahole, not the source code.
