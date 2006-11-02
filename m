From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 2 Nov 2006 17:09:24 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611021703230.2999@mercury.sdinet.de>
References: <20061026050416.GB14199@havoc.gtf.org>
 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
 <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com>
 <4548E7F7.7030100@linux.intel.com> <20061102121657.GA13468@infradead.org>
 <20061102150550.5c30f704@midnight> <20061102141815.GA1795@infradead.org>
 <20061102164213.19bc6176@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.sdinet.de ([193.103.161.30]:14520 "EHLO
	mercury.sdinet.de") by vger.kernel.org with ESMTP id S1751452AbWKBQJ0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 11:09:26 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061102164213.19bc6176@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006, Jiri Benc wrote:

> On Thu, 2 Nov 2006 14:18:15 +0000, Christoph Hellwig wrote:
>> This is not about the name that makes sense.  I think using ethX names
>> for wireless devices is utterly stupid, but it's what all current upstream
>> drivers do, and at least for WE compat we'll have to stick to it.
>
> That's not true. Look at hostap or zd1201, for example. Also, ethX name
> is not needed for WE compatibility. And because of various names used
> by various drivers (madwifi uses ath0, for example) config scripts
> don't depend on ethX name today anyway.

At least the ones used on my machines all do.
(Debian Sarge, Etch and Unstable)
The configfiles can be changed without problems to use any device name, 
but needing to edit various files just for a kernel update would inhibt me 
from just trying a new version until I really know I would not need to go 
back to the old version again.

(Switching wireless from eth1 to eth2 after copying the harddisk contents 
to a new laptop was work enough, but at least expected with a new machine 
and changed hardware)

c'ya
sven

-- 

The Internet treats censorship as a routing problem, and routes around it.
(John Gilmore on http://www.cygnus.com/~gnu/)
