From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: iwlwifi worse than ever in current git.
Date: Tue, 10 Jan 2012 12:53:34 -0600
Message-ID: <1326221614.5067.6.camel@dcbw.foobar.com>
References: <20120110184917.GA26973@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120110184917.GA26973-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-10 at 13:49 -0500, Dave Jones wrote:
> For the last few releases, iwlwifi has been getting consistently worse
> wrt reliability for me.  The failure mode has varied, from the chip just
> locking up with no tx/rx of packets with nothing being logged, to
> microcode warnings, and spewing 'Tx aggregation enabled' messages over and over.

You might want to CC linux-wireless@vger too...

> The merge post 3.2 has made these problems a lot worse.  Before, these
> lock-ups were happening once or twice a day. Now they happen several times an hour
> (and after the first one, they seem more frequent). When they happen,
> unloading and reloading the module is the only way for me to get working wireless again.
> They may happen more frequently when the laptop is not idle.
> 
> I did a bisect of the changes since 3.2, which pointed at 76bc10fcd128ad028cf77c62e179cd20dc2ffecf
> as being the culprit, but to be honest I'm not 100% convinced.
> 
> Because every step of the way during the bisect, I saw different failure modes,
> so when I marked something as 'good', it meant "doesn't lock up in the same way",
> even though it may be symptomatic of the same problem.
> 
> The specific chip I'm using is a 5300 in a Dell Adamo, connecting to
> an Apple airport extreme (current model) in N mode.
> 
> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
