From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 02:37:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414A8614.5000807@pobox.com>
References: <20040917062042.GE6523@zax>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, David Miller <davem@redhat.com>,
        trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Gibson <david@gibson.dropbear.id.au>
In-Reply-To: <20040917062042.GE6523@zax>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Gibson wrote:
> Andrew, please apply:
> 
> When fib_create_info() allocates new hash tables, it neglects to
> initialize them.  This leads to an oops during boot on at least
> machine I use.  This patch addresses the problem.
> 
> Signed-off-by: David Gibson <dwg@au1.ibm.com>


This may be the oops in fib_xxx I just saw on my Athlon64 box...

	Jeff
