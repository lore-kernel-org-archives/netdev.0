From: Ingo Molnar <mingo@elte.hu>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Tue, 31 Aug 2010 21:19:34 +0200
Message-ID: <20100831191934.GA2779@elte.hu>
References: <20100831075705.GA4710@elte.hu>
 <1283251801.2550.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283251801.2550.53.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH] vhost: stop worker only if created

This seems to have done the trick, thanks Eric.

Tested-by: Ingo Molnar <mingo@elte.hu>

> Its illegal to call kthread_stop(NULL)

s/illegal/invalid

Thanks,

	Ingo
