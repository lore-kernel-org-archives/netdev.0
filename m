From: Lincoln Dale <ltd@cisco.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Sat, 14 Jun 2003 15:52:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030614154954.026b4768@mira-sjcm-3.cisco.com>
References: <5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
 <20030613.154634.74748085.davem@redhat.com>
 <20030613231836.GD32097@krispykreme>
 <5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: anton@samba.org, haveblue@us.ibm.com, hdierks@us.ibm.com,
   scott.feldman@intel.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030613.224122.104034261.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 10:41 PM 13/06/2003 -0700, David S. Miller wrote:
>    From: Lincoln Dale <ltd@cisco.com>
>    Date: Sat, 14 Jun 2003 11:52:53 +1000
>
>    unless i misunderstand the problem, you can certainly pad the TCP
>    options with NOPs ...
>
>You may not mangle packet if it is not your's alone.
>
>And every TCP packet is shared with TCP retransmit
>queue and therefore would need to be copied before
>being mangled.

ok, so lets take this a step further.

can we have the TCP retransmit side take a performance hit if it needs to 
realign buffers?

once again, for a "high performance app" requiring gigabit-type speeds, its 
probably fair to say that this is mostly in the realm of applications on a 
LAN rather than across a WAN or internet.
on a switched LAN, i'd expect TCP retransmissions to be far fewer ...


cheers,

lincoln.
