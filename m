From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: raw ipv6 broken in 2.4.19
Date: 14 Aug 2002 01:02:21 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029279741.772.134.camel@tux>
References: <Pine.LNX.4.44.0208140125130.1701-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0208140125130.1701-100000@u.domain.uli>
List-Id: netdev.vger.kernel.org

On Wed, 2002-08-14 at 03:38, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 14 Aug 2002 kuznet@ms2.inr.ac.ru wrote:
> 
> > Well, if this is only in combination with zero length, it is not a disaster.
> 
> 	May be. It seems there were no such callers but they
> appeared. I'm not sure a comment can avoid further problems.
> As for the fix, we don't see often lengths of 0 and 1 for
> unaligned addrs, it is in the slow path in csum_partial. IMHO,
> it will not hurt if we apply the fix instead of auditing everything.

I applied the patch and now it's working fine, both ping6 and
traceroute6 seems to be working fine.

I'll leave it to you guys to debate this :)

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
