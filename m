From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 23:08:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.230850.85410095.davem@redhat.com>
References: <5.1.0.14.2.20030614114755.036abbb0@mira-sjcm-3.cisco.com>
	<20030613.224122.104034261.davem@redhat.com>
	<5.1.0.14.2.20030614154954.026b4768@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, haveblue@us.ibm.com, hdierks@us.ibm.com,
   scott.feldman@intel.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ltd@cisco.com
In-Reply-To: <5.1.0.14.2.20030614154954.026b4768@mira-sjcm-3.cisco.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Lincoln Dale <ltd@cisco.com>
   Date: Sat, 14 Jun 2003 15:52:35 +1000
   
   can we have the TCP retransmit side take a performance hit if it needs to 
   realign buffers?
   
You don't understand, the person who mangles the packet
must make the copy, not the person not doing the packet
modifications.

   for a "high performance app" requiring gigabit-type speeds,

...we probably won't be using ppc64 and e1000 cards, yes, I agree
:-)

Anton, go to the local computer store and pick up some tg3
cards or a bunch of Taiwan specials :-)
