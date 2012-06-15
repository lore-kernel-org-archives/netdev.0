From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH wireless-next 00/20] Use pr_<level>
Date: Fri, 15 Jun 2012 16:37:16 -0700
Message-ID: <1339803436.26435.4.camel@joe2Laptop>
References: <cover.1339739415.git.joe@perches.com>
	 <1339745811.4512.0.camel@jlt3.sipsolutions.net>
	 <1339757319.24527.21.camel@joe2Laptop> <20120615225057.GD7363@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120615225057.GD7363-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-15 at 18:50 -0400, Ted Ts'o wrote:
> On Fri, Jun 15, 2012 at 03:48:39AM -0700, Joe Perches wrote:
> > To tee up conversions of:
> > 	pr_<level>("%s: ...", ([truct netdevice *]foo)->name, ...)
> > to
> > 	netdev_<level>(foo, "...", ...) 
> 
> If the goal is to do the latter, why introduce needless patch churn
> now just to get to pr_<level>?  Having a standardized netdev_<label>()
> adds real benefit that can be weighed against the cost of code churn.
> Why not just wait until the netdev_<level> infrastructure can be
> introduced?  It will save effort on everybody's part.

Not really.  This standardizes prefixes as is.

The newlines and such will still occur.
The git blame noise etc too.

The standardization via spatch will be
significantly easier this way.  It's also
a far easier pattern to verify.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
