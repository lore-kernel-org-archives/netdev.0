From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 17:15:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927171520.632714fa.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
	<20040927160411.22b44f48.davem@davemloft.net>
	<20040927232554.GB15825@wotan.suse.de>
	<20040927163751.274f6071.davem@davemloft.net>
	<20040927235117.GC15825@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, jheffner@psc.edu, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040927235117.GC15825@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 01:51:17 +0200
Andi Kleen <ak@suse.de> wrote:

> Looks like the e1000 is too fast...

Yes, the e1000 does TSO expansion much faster than the MIPS
cpus on the tg3.  I believe the e1000 implementation is
in the ASIC instead of being implemented with a firmware
runing on a general purpose on-board processor.

In the 5705 and later revisions, the tg3 implements TSO
in the ASIC as well.
