From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 3 Jun 2003 23:12:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16093.36319.412668.87363@napali.hpl.hp.com>
References: <16093.30507.661714.676184@napali.hpl.hp.com>
	<3EDD7832.7010804@us.ibm.com>
	<16093.34022.445246.52398@napali.hpl.hp.com>
	<20030603.225245.55753285.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, niv@us.ibm.com,
   kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au, gandalf@wlug.westbo.se,
   linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org, netdev@oss.sgi.com,
   akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030603.225245.55753285.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 03 Jun 2003 22:52:45 -0700 (PDT), "David S. Miller" <davem@redhat.com> said:

  David>    From: David Mosberger <davidm@napali.hpl.hp.com> Date:
  David> Tue, 3 Jun 2003 22:34:30 -0700

  David>    You can't go higher than 1000 conn/sec per client (IP
  David> address) because otherwise you run out of port space (due to
  David> TIME_WAIT).

  DaveM> echo "1" >/proc/sys/net/ipv4/tcp_tw_recycle

  DaveM> It should eliminate this limit.  Unfortunately we can't
  DaveM> enable this by default because of NAT :(

Ah, yes, provided PAWS is enabled, this would give you a time_wait
timeout of 3.5*RTO.  Nice.

	--david
