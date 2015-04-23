From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Thu, 23 Apr 2015 16:55:18 -0700
Message-ID: <1429833318.32612.47.camel@perches.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>
	 <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>
	 <1429492384.27863.13.camel@perches.com> <5536B9D2.7030200@gmail.com>
	 <1429651348.31675.12.camel@perches.com> <5536C4C2.4000001@gmail.com>
	 <1429655247.31675.20.camel@perches.com> <55394DA8.3060705@gmail.com>
	 <1429833248.32612.46.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429833248.32612.46.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-04-23 at 16:54 -0700, Joe Perches wrote:
> On Thu, 2015-04-23 at 21:53 +0200, Mateusz Kulikowski wrote:
> > I noticed funny behavior about $stat matches - 
> > it reports the same error several times (including as "scope" whole file)
> > Is it feature or "feature" or I missed something?
> 
> You have to make sure the first character of $stat is a +
> 
> 	if ($stat =~ /\+(?:.*)\bmem<foo>

Make that

	if ($stat =~ /^\+(?:.*)\bmem<foo>
