From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 17 Jun 2003 12:56:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.125629.85394621.davem@redhat.com>
References: <1055879830.16368.7.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1055879830.16368.7.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 17 Jun 2003 14:57:04 -0500

      That's perfectly fine, a 0-length prefix will cause a matche
      on all addresses.
   
   Ok, I just wanted to verify that.  Here's a patch for your review.

Looks like it would work.

   I call ipv6_addr_prefix on both of the rt6i addresses just in case they
   aren't stored in prefix form at any point now or in the future.

I think this is a bit overkill, can you redo this patch without this?

If we un-prefix'ify ipv6 addresses in the routing entries, we're going
to have to go over the whole tree and audit this kind of stuff
anyways.

Thanks.
