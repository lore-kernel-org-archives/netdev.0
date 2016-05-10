From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 11:51:38 -0400 (EDT)
Message-ID: <20160510.115138.1825421050410315543.davem@davemloft.net>
References: <cover.1462886866.git.pabeni@redhat.com>
	<1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, ast@plumgrid.com,
	aduyck@mirantis.com, tom@herbertland.com, peterz@infradead.org,
	mingo@kernel.org, riel@redhat.com, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 May 2016 07:29:50 -0700

> We already have ksoftirqd to normally cope with the case you are
> describing.
> 
> If it is not working as intended, please identify the bugs and fix them,
> instead of adding yet another tests in fast path and extra complexity in
> the stack.

+1

Indeed, if ksoftirqd is not doing it's job, please fix it.  It is designed
exactly to deal with the problems described here.
