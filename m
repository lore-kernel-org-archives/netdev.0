From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: use oneshot blink API for LED triggers
Date: Thu, 25 Jul 2013 09:58:21 +0200
Message-ID: <1374739101.8827.7.camel@jlt4.sipsolutions.net>
References: <1374624581-6012-1-git-send-email-fabio.baltieri@gmail.com>
	 <1374624581-6012-2-git-send-email-fabio.baltieri@gmail.com>
	 <1374653665.8180.0.camel@jlt4.sipsolutions.net>
	 <20130724085337.GA7096@balto.lan> (sfid-20130724_105341_536708_82A83A0A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Fabio Baltieri <fabio.baltieri-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130724085337.GA7096-lYxsXyORJ9v/PtFMR13I2A@public.gmane.org> (sfid-20130724_105341_536708_82A83A0A)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-24 at 10:53 +0200, Fabio Baltieri wrote:
> On Wed, Jul 24, 2013 at 10:14:25AM +0200, Johannes Berg wrote:
> > On Wed, 2013-07-24 at 02:09 +0200, Fabio Baltieri wrote:
> > > Changes mac80211 LED trigger code to use the generic
> > > led_trigger_blink_oneshot() API for transmit and receive activity
> > > indication.
> > > 
> > > This gives a better feedback to the user, as with the new API each
> > > activity event results in a visible blink, while a constant traffic
> > > results in a continuous blink at constant rate.
> > 
> > This seems a little pointless since our throughput-based trigger can do
> > very similar (but somewhat better) behaviour? Maybe that should just be
> > the default instead, with some sane default setup values?
> 
> Ok but that requires driver specific support and it's only implemented
> on a subset of currently available drivers.

Not necessarily, it's just done that way because we expected everyone to
have their own idea of what the blink speeds should be, possibly even
depending on the maximum speed the hardware can do etc.

> This at least makes the basic tx/rx indication capability a better.

Fair enough.

> > (Regardless of that, you also have indentation problems in your patch)
> 
> Ok, I guess you are referring to the this:
> 
> +       led_trigger_blink_oneshot(local->tx_led,                                
> +                       &led_delay, &led_delay, 0);                             

Yes, that was the place I noticed, didn't check more closely.

> So, are you definitely rejecting this patch or should I fix indentation
> and send a v2?

I think I'll take it, I kinda hope nobody will really care much about it
but the behaviour looks better and the code is simpler, so ... :)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
