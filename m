From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 18:34:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.183440.41634090.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
	<20030613.165250.41635765.davem@redhat.com>
	<20030614005534.GF32097@krispykreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scott.feldman@intel.com, haveblue@us.ibm.com, hdierks@us.ibm.com,
   dwg@au1.ibm.com, linux-kernel@vger.kernel.org, milliner@us.ibm.com,
   ricardoz@us.ibm.com, twichell@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org
In-Reply-To: <20030614005534.GF32097@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Anton Blanchard <anton@samba.org>
   Date: Sat, 14 Jun 2003 10:55:34 +1000

   What I think is happening is that we arent tripping the prefetch
   logic.  We should take a latency hit for only the first cacheline
   at which point the host bridge decides to start prefetching for
   us. If not then we take take the latency hit on each transaction.

It sounds like what happens is that the sub-cacheline word reads
don't trigger the prefetch, but the first PCI read multiple
transaction does.
