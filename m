From: "David S. Miller" <davem@redhat.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 22:52:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.225245.55753285.davem@redhat.com>
References: <16093.30507.661714.676184@napali.hpl.hp.com>
	<3EDD7832.7010804@us.ibm.com>
	<16093.34022.445246.52398@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au,
   gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org,
   linux-ia64@linuxia64.org, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com, davidm@napali.hpl.hp.com
In-Reply-To: <16093.34022.445246.52398@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: David Mosberger <davidm@napali.hpl.hp.com>
   Date: Tue, 3 Jun 2003 22:34:30 -0700
   
   You can't go higher than 1000 conn/sec per client (IP address)
   because otherwise you run out of port space (due to TIME_WAIT).

echo "1" >/proc/sys/net/ipv4/tcp_tw_recycle

It should eliminate this limit.  Unfortunately we can't enable
this by default because of NAT :(
