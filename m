From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 18:26:57 +0100
Message-ID: <20160921182657.67681e67@jkicinski-Precision-T1700>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <57E1CDE3.5030404@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        <tariqt@mellanox.com>, <bblanco@plumgrid.com>,
        <alexei.starovoitov@gmail.com>, <eric.dumazet@gmail.com>,
        <brouer@redhat.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:49110 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757272AbcIUR1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 13:27:12 -0400
In-Reply-To: <57E1CDE3.5030404@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 17:01:39 -0700, Alexei Starovoitov wrote:
>  >  - Reduces the amount of code and complexity needed in drivers to
>  >    manage XDP  
> 
> hmm:
> 534 insertions(+), 144 deletions(-)
> looks like increase in complexity instead.

and more to come to tie this with HW offloads.
