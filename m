From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 3 Jun 2003 23:19:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16093.36723.418623.698303@napali.hpl.hp.com>
References: <200306040043.EAA24505@dub.inr.ac.ru>
	<3EDD52F5.8090706@us.ibm.com>
	<20030603.202320.59680883.davem@redhat.com>
	<16093.30507.661714.676184@napali.hpl.hp.com>
	<3EDD7832.7010804@us.ibm.com>
	<16093.34022.445246.52398@napali.hpl.hp.com>
	<3EDD8BD2.9040008@us.ibm.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, "David S. Miller" <davem@redhat.com>,
   kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au, gandalf@wlug.westbo.se,
   linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org, netdev@oss.sgi.com,
   akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3EDD8BD2.9040008@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 03 Jun 2003 23:04:02 -0700, Nivedita Singhvi <niv@us.ibm.com> said:

  Nivedita> Those should be TCPAbortOnTimeout counts, rather than
  Nivedita> TCPAbortFailed errors, I would expect? Why AbortFailed?
  Nivedita> Coming from IP via tcp_transmit_skb()?

Yes, the "connection hangs/disappearances" where triggered by
TCPAbortOnTimeout; the TCPAbortFailed errors were indicating that
tcp_transmit_skb() had failed, i.e., the tx queue was overrun (that's
were the losses came from).

	--david
