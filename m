From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: use oneshot blink API for LED triggers
Date: Wed, 24 Jul 2013 10:14:25 +0200
Message-ID: <1374653665.8180.0.camel@jlt4.sipsolutions.net>
References: <1374624581-6012-1-git-send-email-fabio.baltieri@gmail.com>
	 <1374624581-6012-2-git-send-email-fabio.baltieri@gmail.com>
	 (sfid-20130724_020950_576315_9E59DD81)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fabio Baltieri <fabio.baltieri@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374624581-6012-2-git-send-email-fabio.baltieri@gmail.com> (sfid-20130724_020950_576315_9E59DD81)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-24 at 02:09 +0200, Fabio Baltieri wrote:
> Changes mac80211 LED trigger code to use the generic
> led_trigger_blink_oneshot() API for transmit and receive activity
> indication.
> 
> This gives a better feedback to the user, as with the new API each
> activity event results in a visible blink, while a constant traffic
> results in a continuous blink at constant rate.

This seems a little pointless since our throughput-based trigger can do
very similar (but somewhat better) behaviour? Maybe that should just be
the default instead, with some sane default setup values?

(Regardless of that, you also have indentation problems in your patch)

johannes
