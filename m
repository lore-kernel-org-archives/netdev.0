From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 Extension headers
Date: Sun, 23 Mar 2003 21:29:50 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030323.212950.05858732.davem@redhat.com>
References: <20030306093219.1a702868.kazunori@miyazawa.org>
	<20030305.204348.130225511.davem@redhat.com>
	<87of48h6f8.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <87of48h6f8.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Tue, 18 Mar 2003 10:32:27 -0800
   
   Could you check this patch?
   (This patch is against 2.5.65.)

I applied this patch with some minor changes.

First, many functions in net/ipv6/exthdrs.c and net/ipv6/reassembly.c
can be marked static now.

Second, some local variables (for example, "nhoff" in ip6_input()) can
be eliminated entirely because they compute a value in one place and
use it in the very next line and nowhere else is it referenced.

Thank you.
