From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 15:46:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.154634.74748085.davem@redhat.com>
References: <OF0078342A.E131D4B1-ON85256D44.0051F7C0@pok.ibm.com>
	<1055521263.3531.2055.camel@nighthawk>
	<20030613223841.GB32097@krispykreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haveblue@us.ibm.com, hdierks@us.ibm.com, scott.feldman@intel.com,
   dwg@au1.ibm.com, linux-kernel@vger.kernel.org, milliner@us.ibm.com,
   ricardoz@us.ibm.com, twichell@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org
In-Reply-To: <20030613223841.GB32097@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Anton Blanchard <anton@samba.org>
   Date: Sat, 14 Jun 2003 08:38:41 +1000
   
   This is only worth it if most packets will have the same sized header.
   Networking guys: is this a valid assumption?

Not really... one retransmit and the TCP header size grows
due to the SACK options.

I find it truly bletcherous what you're trying to do here.

Why not instead find out if it's possible to have the e1000
fetch the entire cache line where the first byte of the packet
resides?  Even ancient designes like SunHME do that.
