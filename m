From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Fri, 3 Jun 2005 22:29:05 -0700
Message-ID: <20050604052905.GA8130@jm.kir.nu>
References: <20050602190232.340996282D7@mail.suse.cz> <20050603113343.55d19cfc@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gwingerde@home.nl, netdev@oss.sgi.com, jbohac@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050603113343.55d19cfc@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 11:33:43AM +0200, Jiri Benc wrote:

> and so on. Also WLAN_STATUS_ASSOC_DENIED_NOSHORT seems to be acceptable
> for me.

That would be just asking for problems. IEEE 802.11 uses "short" in
number of terms and two of them happen to be already part of
capabilities negotatiation (short preamble and short slot time) and both
have status codes for rejecting association.. In other words, the
constants/enums better include PREAMBLE and SLOTTIME in the name.

-- 
Jouni Malinen                                            PGP id EFC895FA
