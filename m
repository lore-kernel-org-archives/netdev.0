From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: IPv6 random failures
Date: Thu, 22 May 2003 15:54:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.155408.85396915.davem@redhat.com>
References: <OF5D0301D4.91C949F2-ON86256D2E.0061C9C3-86256D2E.006456C0@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OF5D0301D4.91C949F2-ON86256D2E.0061C9C3-86256D2E.006456C0@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Thu, 22 May 2003 13:15:58 -0500
   
   It would seem that the flowi structure should use the actual IPv6
   addresses instead of pointers to them, like the IPv4 section does.
   Feedback?

Yes, precisely, thanks for spotting this.  I introduced this
bug when I split out the policy flow cache into a generic spot.

I'll see how much work it is to change all of ipv6 to store
addresses directly into the flowi's instead of via pointers.
