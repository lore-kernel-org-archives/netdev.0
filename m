From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Mon, 23 Nov 2009 11:01:46 -0800
Message-ID: <1259002906.5022.36.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <4B063509.10006@gmail.com> <1258734101.11049.1.camel@localhost.localdomain>
	 <200911231138.30755.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200911231138.30755.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rusty,

On Mon, 2009-11-23 at 11:38 +1030, Rusty Russell wrote:
> Overall, the patch looks good.  But it would have been nicer if it
> were
> split into several parts: cleanups, new infrastructure, then the
> actual
> allocation change.

I have split the patch into a set: cleanups, new infrastructure, and
actual allocation change in add buffers: add_recvbuf_big,
add_recvbuf_small, add_recvbuf_mergeage per your suggestion, and also in
recv buffers: recv_big, recv_small, recv_mergeable.

I hope you will agree with it. I am testing the patch-set now, will
submit it soon after finishing all test cases.

Thanks
Shirley

