From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 14:27:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714122738.GF2269@elf.ucw.cz>
References: <20040714114135.GA25175@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267367AbUGNMaZ@vger.kernel.org>
To: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040714114135.GA25175@elf.ucw.cz>
List-Id: netdev.vger.kernel.org

Hi!

> What is the status of ipw2100? Is there chance that it would be pushed
> into mainline?

Hmm, it has very "nice" interface in proc, where it tells you (in
english *sentences*) if radio kill switch is enabled or not. Ouch.

iwconfig eth1 mode ad-hoc

followed by

iwconfig eth1

makes it crash in ipw2100_wx_get_power called from
wireless_process_ioctl.

								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
