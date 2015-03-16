From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: Clean up inet_csk_wait_for_connect() vs.
 might_sleep()
Date: Mon, 16 Mar 2015 15:24:27 -0700
Message-ID: <1426544667.11398.231.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150316.171243.1969465707208233939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150316.171243.1969465707208233939.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-16 at 17:12 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 16 Mar 2015 12:19:24 -0700
> 
> > In commit 26cabd31259ba43f68026ce3f62b78094124333f
> > Peter added a sched_annotate_sleep() in sk_wait_event()
> > 
> > Is the following patch needed as well ?
> 
> Who is asking this question and who is it directed at?
> 
> It looks like something that needs to be resolved before I apply this
> patch, right?

I was asking the question to Peter ;)

It's a patch that should enter one of your tree, but I would like a
comment from Peter or anyone fully understanding the issue.
