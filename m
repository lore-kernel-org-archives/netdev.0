From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH RESEND] memory leak in ndisc_router_discovery
Date: Fri, 20 Dec 2002 23:08:36 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021220.230836.40590865.davem@redhat.com>
References: <200212121905.gBCJ5hn18058@eng2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <200212121905.gBCJ5hn18058@eng2.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Thu, 12 Dec 2002 11:05:43 -0800 (PST)

   I had sent this earlier, there is a bug in router advertisement handling code,
   where the reference (and memory) to an inet6_dev pointer can get leaked (this
   leak can happen atmost once for each interface on a system which receives
   invalid RA's). Below is the patch against 2.5.51 to fix it.

Applied, thanks.
