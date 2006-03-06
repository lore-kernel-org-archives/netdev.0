From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for
	RDMA connection manager
Date: Mon, 06 Mar 2006 14:39:01 -0800 (PST)
Message-ID: <20060306.143901.26500391.davem@davemloft.net>
References: <adabqwj5j7b.fsf@cisco.com>
	<20060306.142814.109285730.davem@davemloft.net>
	<aday7zn432b.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <aday7zn432b.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 06 Mar 2006 14:32:28 -0800

> The fundamental question seems to be whether things like
> 
> 	struct foo {
> 		struct sockaddr_in6 src;
> 		struct sockaddr_in6 dst;
> 	};
> 
> and
> 
> 	struct bar {
> 		struct sockaddr_in6 a;
> 		__u32 b;
> 	};

I wrote a test program and it looks ok:

davem@sunset:~/src/GIT/sparc-2.6.17$ gcc -m32 -O -o foo foo.c
davem@sunset:~/src/GIT/sparc-2.6.17$ ./foo
SPARC32
foo src: 0
foo dst: 28
bar a: 0
bar b: 28
davem@sunset:~/src/GIT/sparc-2.6.17$ gcc -m64 -O -o foo foo.c
davem@sunset:~/src/GIT/sparc-2.6.17$ ./foo
SPARC64
foo src: 0
foo dst: 28
bar a: 0
bar b: 28
