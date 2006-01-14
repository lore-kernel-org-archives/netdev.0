From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: wireless: recap of current issues (compatibility)
Date: Sat, 14 Jan 2006 14:44:03 +0100
Message-ID: <m3u0c69b6k.fsf@defiant.localdomain>
References: <20060113195723.GB16166@tuxdriver.com>
	<20060113212605.GD16166@tuxdriver.com>
	<20060113213126.GF16166@tuxdriver.com>
	<20060113222054.GK16166@tuxdriver.com>
	<1137191590.2520.65.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030437AbWANNoS@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1137191590.2520.65.camel@localhost> (Johannes Berg's message of "Fri, 13 Jan 2006 23:33:10 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> If you want the old userspace API to 'just work' you have to create one
> default wlan device at WiPHY init.

I'm not sure the old API is that important. This isn't something
programs (third party, kernel utils don't count) rely on. Most users
would switch to the new stack immediately anyway.

It could probably be a separate compatibility module, the core stack
probably don't have to know about it. The last to worry about I'd say.
-- 
Krzysztof Halasa
