From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 22:41:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.224122.104034261.davem@redhat.com>
References: <20030613.154634.74748085.davem@redhat.com>
	<20030613231836.GD32097@krispykreme>
	<5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, haveblue@us.ibm.com, hdierks@us.ibm.com,
   scott.feldman@intel.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ltd@cisco.com
In-Reply-To: <5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Lincoln Dale <ltd@cisco.com>
   Date: Sat, 14 Jun 2003 11:52:53 +1000
   
   unless i misunderstand the problem, you can certainly pad the TCP
   options with NOPs ...

You may not mangle packet if it is not your's alone.

And every TCP packet is shared with TCP retransmit
queue and therefore would need to be copied before
being mangled.
