From: Peter Bieringer <pb@bieringer.de>
Subject: Re: IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with algopatches 0.8.1rc2
 (in)compatible encryption methods
Date: Fri, 06 Jun 2003 08:25:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <122560000.1054880747@gate.muc.bieringer.de>
References: <35410000.1054818456@klopffest.muc.aerasec.de>
 <20030605.215907.71090944.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030605.215907.71090944.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, June 05, 2003 09:59:07 PM -0700 "David S. Miller"
<davem@redhat.com> wrote:

>    From: "Dr. Peter Bieringer" <pb@bieringer.de>
>    Date: Thu, 05 Jun 2003 15:07:36 +0200
> 
>    because I got no success, I've tried different encryption methods than 
>    3DES. And *suddenly* it began to work.
>    
> Sounds like an out-of-date include/linux/pfkeyv2.h file
> used during tool building.

Yes, it looks like.

BTW: is there something like a "version information" which is used in that
way that user space tools can detect and report such changes at runtime?
Would be perhaps helpful if racoon reports something like "incompatible" in
this case. Very much better than such strange problems...

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
