From: Lincoln Dale <ltd@cisco.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Sat, 14 Jun 2003 11:52:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
References: <20030613.154634.74748085.davem@redhat.com>
 <OF0078342A.E131D4B1-ON85256D44.0051F7C0@pok.ibm.com>
 <1055521263.3531.2055.camel@nighthawk>
 <20030613223841.GB32097@krispykreme>
 <20030613.154634.74748085.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: "David S. Miller" <davem@redhat.com>, haveblue@us.ibm.com,
   hdierks@us.ibm.com, scott.feldman@intel.com, dwg@au1.ibm.com,
   linux-kernel@vger.kernel.org, milliner@us.ibm.com, ricardoz@us.ibm.com,
   twichell@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20030613231836.GD32097@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 09:18 AM 14/06/2003 +1000, Anton Blanchard wrote:

> > Not really... one retransmit and the TCP header size grows
> > due to the SACK options.
>
>OK scratch that idea.

why not have a performance option that is a tradeoff between optimum 
payload size versus efficiency.

unless i misunderstand the problem, you can certainly pad the TCP options 
with NOPs ...

> > I find it truly bletcherous what you're trying to do here.
>
>I think so too, but its hard to ignore ~100Mbit/sec in performance.

another option is for the write() path is for instantant-send TCP sockets 
to delay the copy_from_user() until the IP+TCP header size is known.
i wouldn't expect the net folks to like that, however ..


cheers,

lincoln.
