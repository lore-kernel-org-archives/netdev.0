From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Thu, 12 Jun 2003 01:21:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.012100.83594413.davem@redhat.com>
References: <1055352036.2610.42.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1055352036.2610.42.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 11 Jun 2003 12:20:33 -0500

   As for the bug though, it appears that the "x->u.rt.fl = *fl"
   statement shouldn't be performed in the IPv6 __xfrm6_bundle_create
   function.

I have a better suggestion for fix:

1) Delete the "x->u.rt.fl = *fl;" line completely.

2) Fix the test in __xfrm6_find_bundle() to do a proper
   prefix-mask based address comparison.

   rt6->rt6i_{dst,src} are masked addresses, so direct
   comparison is wrong.

Can someone code this up?
Thanks.
