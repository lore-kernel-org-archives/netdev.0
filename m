From: Alex Bligh <alex@alex.org.uk>
Subject: Re: kernel panic in skb_copy_bits
Date: Sun, 30 Jun 2013 10:35:57 +0100
Message-ID: <BADA533A15AA8D67FC64EFAA@nimrod.local>
References: <51CBAA48.3080802@oracle.com>
 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
 <6BFD5AF235F72F13CE646A0D@nimrod.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Alex Bligh <alex@alex.org.uk>
To: Alex Bligh <alex@alex.org.uk>, Joe Jin <joe.jin@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:49144 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab3F3JgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 05:36:12 -0400
In-Reply-To: <6BFD5AF235F72F13CE646A0D@nimrod.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 30 June 2013 10:13:35 +0100 Alex Bligh <alex@alex.org.uk> wrote:

> The nature of the bug
> is extensively discussed in that thread - you'll also find
> a reference to a thread on linux-nfs which concludes it
> isn't an nfs problem, and even some patches to fix it in the
> kernel adding reference counting.

Some more links for anyone interested in fixing the kernel bug:

 http://lists.xen.org/archives/html/xen-devel/2013-01/msg01618.html
 http://www.spinics.net/lists/linux-nfs/msg34913.html
 http://www.spinics.net/lists/netdev/msg224106.html

-- 
Alex Bligh
