From: Dave Jones <davej@redhat.com>
Subject: Re: latest -stable breaks Squid
Date: Thu, 4 May 2006 19:47:42 -0400
Message-ID: <20060504234742.GS18962@redhat.com>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au> <4459574D.6000303@candelatech.com> <cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com> <20060504.162546.88959729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: imcdnzl@gmail.com, greearb@candelatech.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	stable@kernel.org, fedora-list@list.zikzak.de,
	fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:27528 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030284AbWEDXsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 19:48:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060504.162546.88959729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 04:25:46PM -0700, David S. Miller wrote:

 > That being said, the first thing that should be tried is reverting
 > the above mentioned change and see if the problem goes away.  If
 > so, then we need to investigate what the bandwidth delay product is
 > for the connection, and whether the socket send buffer is set large
 > enough for that size of pipe.

It's now believed (after some detective work from Herbert) that
this round of problems wasn't caused by the -stable patch, but
by a bogus update to Xen which we carry in the Fedora kernel
that sneaked in without a changelog (which is why I didn't even suspect that thing
given it worked fine previously).

Until today I had no idea just how much that thing poked into net/

Ugh.  Apologies for the false alarm.

		Dave

-- 
http://www.codemonkey.org.uk
