From: Christoph Lameter <cl@linux.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 12:46:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1103171245430.16620@router.home>
References: <1300371834.6315.93.camel@edumazet-laptop>  <20110317.081420.71114992.davem@davemloft.net>  <alpine.DEB.2.00.1103171016270.12540@router.home> <1300380801.6315.306.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1300380801.6315.306.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2011, Eric Dumazet wrote:

> When we know we run from BH context, we can use __this_cpu_inc(), but if
> we dont know or run from user/process context, we would need irqsafe_inc
> variant.

If the BH context is the only one where we care about performance then its
ok I would think.
