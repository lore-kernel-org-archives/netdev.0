From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCHv3 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Wed, 09 Apr 2014 09:32:31 -0600
Message-ID: <5345680F.3040903@wwwdotorg.org>
References: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com> <1396946275.5936.2.camel@jlt4.sipsolutions.net> <20140409100147.GB3083@xps8300>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140409100147.GB3083@xps8300>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/09/2014 04:01 AM, Heikki Krogerus wrote:
> Hi,
> 
> On Tue, Apr 08, 2014 at 10:37:55AM +0200, Johannes Berg wrote:
>> On Tue, 2014-04-01 at 17:02 +0300, Heikki Krogerus wrote:
>>> I hope this one is OK with everyone.
>>
>> It's fine with me. Are you expecting me to pick up any of these patches,
>> or do you want them to go through some other tree? Either way is fine
>> with me, but the first patch looks like something I probably shouldn't
>> be taking.
> 
> The second patch depends on it.
> 
> Stephen! Are you expecting any changes to board-paz00.c in this kernel
> cycle? If not, I think it would be easiest if Johannes, you take the
> whole set. What do you guys think?

I can't predict the future, but the chances are pretty slim - that file
is pretty tiny and doesn't have much churn.

The best approach is to put this series in its own topic branch. Then,
if any conflict does come up, I can simply merge the branch into the
Tegra treee and apply the conflicting patches on top.
