From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Sun, 15 Jun 2003 07:44:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.074405.39168044.davem@redhat.com>
References: <OF7D02DC37.06BCABE8-ON85256D46.004E9127@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ltd@cisco.com, anton@samba.org, haveblue@us.ibm.com,
   scott.feldman@intel.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hdierks@us.ibm.com
In-Reply-To: <OF7D02DC37.06BCABE8-ON85256D46.004E9127@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Herman Dierks" <hdierks@us.ibm.com>
   Date: Sun, 15 Jun 2003 09:40:41 -0500
   
   With TSO being the default,   the small packet case
   becomes less important anyway.

This is a very narrow and unrealistic view of the situation.

Every third packet your system will process for any connection will be
an ACK, a small packet.  Most database and web and database
transactions happen using small packets for the transaction request.

Look, if you're gonna sit here and just rant justifying this bogus
behavior of your hardware, it is likely to go in one ear and out the
other.  Nobody wants to hear excuses. :)

The fact is, this system handles sub-cacheline reads inefficiently
even if a sequences of transactions are consequetive and to the same
cache line and no coherency transactions occur to that cache line.

That is dumb, and there is no arguing around this.  You would be
sensible to realize this, and accept it whilst others try to help you
find a solution for your problem.
