From: "David S. Miller" <davem@redhat.com>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 03 Oct 2002 00:59:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.005907.62651859.davem@redhat.com>
References: <1033388585.16337.9.camel@irongate.swansea.linux.org.uk>
	<Mutt.LNX.4.44.0210031329450.13240-100000@blackbird.intercode.com.au>
	<20021003035446.GA29860@averell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, alan@lxorguk.ukuu.org.uk, mbp@samba.org,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <20021003035446.GA29860@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@muc.de>
   Date: Thu, 3 Oct 2002 05:54:46 +0200

   On Thu, Oct 03, 2002 at 05:30:44AM +0200, James Morris wrote:
   > On 30 Sep 2002, Alan Cox wrote:
   > 
   > > Well if Dave can't test it and isnt doing any 2.2 who wants to be the
   > > 2.2 networking maintainer ?
   > > 
   > 
   > I'd be willing to give it a go.
   
   2.2 networking unfortunately has some more SMP bugs (DaveM can tell you details)
   which are hard to fix. So think twice before you volunteer ;)

These don't matter as much as you may think.

The real show stoppers are the ones like this FIN_WAIT1 cork
bug.

These are the only ones we can come up with safe fixes (in terms of
what this means for 2.2.x) for anyways.

Franks a lot,
David S. Miller
davem@redhat.com
