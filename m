From: "David S. Miller" <davem@redhat.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 20:23:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.202320.59680883.davem@redhat.com>
References: <200306040043.EAA24505@dub.inr.ac.ru>
	<3EDD52F5.8090706@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au, davidm@hpl.hp.com,
   gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org,
   linux-ia64@linuxia64.org, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3EDD52F5.8090706@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Tue, 03 Jun 2003 19:01:25 -0700
   
   But, FYI, DaveM and Alexey, we tried
   reproducing the stalls we (Dave Hansen, Troy Wilson) had
   seen during SpecWeb99 runs and couldn't reproduce them on
   2.5.69. (Same config, etc). So its possible our hang/stalls
   were some other issue that got silently fixed (or more
   likely, possibly the same thing but other changes minimized
   us running into the problem).
   
I think this means nothing, and that you can infer nothing from such
results.

My understanding is that the problem case triggers only when a timeout
based retransmit occurs.  On LAN this tends to be extremely rare.
Although under enough traffic load it can occur.

So if your old SpecWEB99 lab tended more to trigger timeout based
retransmits on LAN, and your new test network does not, then your new
test network will tend to not reproduce the bug regardless of whether
the bug is present in the kernel or not :-)
