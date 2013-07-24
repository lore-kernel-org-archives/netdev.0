From: Fabio Baltieri <fabio.baltieri@gmail.com>
Subject: Re: [PATCH] mac80211: use oneshot blink API for LED triggers
Date: Wed, 24 Jul 2013 10:53:37 +0200
Message-ID: <20130724085337.GA7096@balto.lan>
References: <1374624581-6012-1-git-send-email-fabio.baltieri@gmail.com>
 <1374624581-6012-2-git-send-email-fabio.baltieri@gmail.com>
 <1374653665.8180.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1374653665.8180.0.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 24, 2013 at 10:14:25AM +0200, Johannes Berg wrote:
> On Wed, 2013-07-24 at 02:09 +0200, Fabio Baltieri wrote:
> > Changes mac80211 LED trigger code to use the generic
> > led_trigger_blink_oneshot() API for transmit and receive activity
> > indication.
> > 
> > This gives a better feedback to the user, as with the new API each
> > activity event results in a visible blink, while a constant traffic
> > results in a continuous blink at constant rate.
> 
> This seems a little pointless since our throughput-based trigger can do
> very similar (but somewhat better) behaviour? Maybe that should just be
> the default instead, with some sane default setup values?

Ok but that requires driver specific support and it's only implemented
on a subset of currently available drivers.

This at least makes the basic tx/rx indication capability a better.

> (Regardless of that, you also have indentation problems in your patch)

Ok, I guess you are referring to the this:

+       led_trigger_blink_oneshot(local->tx_led,                                
+                       &led_delay, &led_delay, 0);                             

So, are you definitely rejecting this patch or should I fix indentation
and send a v2?

Thanks,
Fabio

-- 
Fabio Baltieri
