From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Fri, 9 May 2014 09:38:41 +0200
Message-ID: <20140509073841.GC4965@xo-6d-61-c0.localdomain>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <20140505.231229.136734008603421707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140505.231229.136734008603421707.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2014-05-05 23:12:29, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon,  5 May 2014 15:25:57 -0700
> 
> > This is all the code that saves connection information
> > between different sockets. Not really essential for
> > small systems.
> 
> It is absolutely essential unless you want poor performance
> of TCP connections.

Sounds like "poor" performance of TCP and 400KB memory free is tradeoff that
makes for small machines.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
