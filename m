From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 18:46:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808201842350.18947@twin.jikos.cz>
References: <20080819.041706.261399060.davem@davemloft.net>
 <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
 <1219170451.7591.175.camel@violet.holtmann.net>
 <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
 <1219203753.7591.205.camel@violet.holtmann.net>  <20080820143734.GB20632@tuxdriver.com>
  <alpine.LFD.1.10.0808200826530.3324@nehalem.linux-foundation.org>
 <1219246813.7591.347.camel@violet.holtmann.net>
 <alpine.LFD.1.10.0808200853410.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:49792 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838AbYHTQqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 12:46:38 -0400
In-Reply-To: <alpine.LFD.1.10.0808200853410.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Aug 2008, Linus Torvalds wrote:

>  - but as a special case, we relax that for totally new drivers (and that 
>    includes things like just adding a new PCI or USB ID's to old drivers), 
>    because (a) it can't really regress 

It in fact depends on your definition of regression really :)

If we merge a buggy driver that hangs the user's machine when loaded, well 
... before the driver has been merged, the machine had been booting well, 
just some hardware was not functioning at all. After this late driver 
merge, the driver gets autoloaded upon boot and crashes the machine. Users 
will probably see this as a regression.

This doesn't mean that I am against merging new drivers as aggressively as 
possible, I just wanted to point out that it might bring actual 
regressions to users.

-- 
Jiri Kosina
SUSE Labs

