From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: typo, unrequired #undef and killing warning
Date: Tue, 03 Jun 2003 23:08:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.230803.10324588.davem@redhat.com>
References: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>
	<20030604070801.A7938@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, vnuorval@tcs.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@infradead.org
In-Reply-To: <20030604070801.A7938@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@infradead.org>
   Date: Wed, 4 Jun 2003 07:08:01 +0100

   This still is not the right codingstyle :) it should be
   
   	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
   
I'll take care of this, Yoshfuji you do not need to
make a new patch :)
