From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Tue, 28 Jun 2016 10:33:59 -0700
Message-ID: <CAM_iQpWBrhksmXFvbp=mtmBCzjZ8McBkgn_e3ZHx7UqSLcvDZA@mail.gmail.com>
References: <57720369.6040507@huawei.com> <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
 <5772149D.6040304@huawei.com> <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ding Tianhong <dingtianhong@huawei.com>, luto@kernel.org,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 27, 2016 at 11:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Lot of this code was written decade ago where nobody expected a root
> user was going to try hard to crash its host ;)

+1

Adding cond_resched() to appropriate network notifiers sounds better.
