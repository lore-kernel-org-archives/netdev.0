From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 15:08:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.150849.132446622.davem@redhat.com>
References: <16111.18107.699689.704597@robur.slu.se>
	<20030617200721.GA25773@netnation.com>
	<Pine.LNX.4.51.0306171753170.13782@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306171753170.13782@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 17 Jun 2003 18:11:00 -0400 (EDT)
   
   My (obviously incorrect) assumption would
   be that fib_validate_source is responsible for rp_filter, and turning it
   off would lead to only a 5% performance increase.

fib_validate_source() with rp_filter enabled causes an extra
fib_lookup() to occur for each packet.
