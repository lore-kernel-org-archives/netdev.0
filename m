From: "David S. Miller" <davem@redhat.com>
Subject: Re: Mail delivery failed: returning message to sender
Date: Tue, 20 May 2003 19:31:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.193119.55733737.davem@redhat.com>
References: <20030520.175553.35669773.davem@redhat.com>
	<200305210222.GAA13659@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200305210222.GAA13659@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Wed, 21 May 2003 06:22:10 +0400 (MSD)
   
   > Russel, please retest using this patch.  This piece of
   > code needs to be audited further.
   
   Relax, it is right now.
   
   I hope it is the only place where route is copied as whole.

I explicitly zeroed out child and xfrm in my final version.
These should never be non-NULL, it is pure paranoia on my part :-)

IP6 makes this more intelligently using ip6_route_copy() function.
We should probably make similar beast for ipv4 just for clarity's
sake.
