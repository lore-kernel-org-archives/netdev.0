From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 11:48:45 -0700 (PDT)
Message-ID: <20090727.114845.177925839.davem@davemloft.net>
References: <4A6D7285.9080909@gmail.com>
	<b5ddba180907270334m4bc4e968m85c16ea4756c3f5d@mail.gmail.com>
	<20090727131357.9561.39720.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	lvs-users@linuxvirtualserver.org, malcolm@loadbalancer.org,
	linux-kernel@vger.kernel.org, horms@verge.net.au
To: heder@google.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754165AbZG0Ssj@vger.kernel.org>
In-Reply-To: <20090727131357.9561.39720.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <heder@google.com>
Date: Mon, 27 Jul 2009 15:13:57 +0200

> No more guessing, how much memory used by IPVS for a connection.
> 
> [ The number printed is a lower bound, as ip_vs_conn_cache uses
> SLAB_HWCACHE_ALIGN. ]
> 
> Signed-off-by: Hannes Eder <heder@google.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Who needs to know this?  A developer?

They can run tools such as 'pahole' et al. to fish out this
information even when only a kernel binary is available.

For the user, it's just noise.

I'm not applying this, sorry.
