From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 16:52:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.165250.41635765.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, haveblue@us.ibm.com, hdierks@us.ibm.com, dwg@au1.ibm.com,
   linux-kernel@vger.kernel.org, milliner@us.ibm.com, ricardoz@us.ibm.com,
   twichell@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Feldman, Scott" <scott.feldman@intel.com>
   Date: Fri, 13 Jun 2003 16:52:18 -0700

   > > Why not instead find out if it's possible to have the e1000 
   > > fetch the entire cache line where the first byte of the
   > > packet resides?  Even ancient designes like SunHME do that.
   > 
   > Rusty and I were wondering why the e1000 didnt do that exact thing.
   > 
   > Scott: is it possible to enable such a thing?
   
   I thought the answer was no, so I double checked with a couple of
   hardware guys, and the answer is still no.

Sigh...

So Anton, when the PCI controller gets a set of sub-cacheline word
reads from the device, it reads the value from memory once for every
one of those words?  ROFL, if so...  I can't believe they wouldn't
put caches on the PCI controller for this, at least a one-behind that
snoops the bus :(
