From: "David S. Miller" <davem@redhat.com>
Subject: Re: confuzed bit flags
Date: Thu, 08 May 2003 15:41:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.154143.88024940.davem@redhat.com>
References: <20030508153032.06e7c98a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org
In-Reply-To: <20030508153032.06e7c98a.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Thu, 8 May 2003 15:30:32 -0700
   
   I'm confused or the source code is or both.
   
   net/ipv6/ndisc.c sets
   
   	rt->rt6i_flags    = RTF_LOCAL;
   
Any time you see some absolutely strange handling inside of ipv6
routing, it usually indicates a place where ipv4 routing does things
one way and the ipv6 side cannot implement things in that way for one
reason or another.  Yet, some ipv4'lets remain in the ipv6 code,
almost as a marker to be mindful of this difference.

This RTF_LOCAL thing is just such a case.

In many ways the ipv6 routing code is lacking in features that
ipv4 routing has.  I'm in fact right now killing on of them,
rtnetlink route metrics are ignored by ipv6.
