From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Fri, 10 Nov 2006 15:26:48 -0800 (PST)
Message-ID: <20061110.152648.88472160.davem@davemloft.net>
References: <4554A7CD.6040907@hp.com>
	<20061110.145507.112290147.davem@davemloft.net>
	<45550872.6050900@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45023
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946761AbWKJX06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 18:26:58 -0500
To: niv@us.ibm.com
In-Reply-To: <45550872.6050900@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nivedita Singhvi <niv@us.ibm.com>
Date: Fri, 10 Nov 2006 15:17:06 -0800

WATCH YOUR QUOTING!

> David Miller wrote:
> > From: Brian Haley <brian.haley@hp.com>
> > Date: Fri, 10 Nov 2006 11:24:45 -0500
> > 
> >> Only change upper-layer checksum from 0 to 0xFFFF for UDP (as RFC 768 
> >> states), not for others as RFC 4443 doesn't require it.
> >>
> >> Signed-off-by: Brian Haley <brian.haley@hp.com>
> > 
> > Applied, thanks Brian.

I applied Brian's FIRST PATCH, which is fine.

> Brian Haley wrote:
>  > Al Viro wrote:
>  >> Could you fscking read what you've replied to?  Your -=1 will turn 0
>  >> into 0xffff instead of correct 0xfffe.  IOW, it's broken in 1:65536
>  >> cases.
>  >
>  > I looked again at your previous email:
>  >
>  >> Note that even on little-endian you want
>  >>     3 -> 2
>  >>     2 -> 1
>  >>     1 -> 0xffff
>  >>     0 -> 0xfffe
>  >
>  > That doesn't look right to me, but I'll take your word that there's one
>  > edge case out there I don't see (even though this worked on Alpha).
>  > Forget about the patch then.
> 
> Er, given all of the above, Brian, could you share your test cases
> and/or other/any information on testing this?

This is a discussion about Brian's SECOND PATCH which needs
fixups.

Please don't quote things out of context like this!
