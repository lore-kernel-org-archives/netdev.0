From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:55:11 -0700 (PDT)
Message-ID: <20170407.125511.1233528940652477012.davem@davemloft.net>
References: <20170407193550.GA23424@salvia>
        <20170407.124327.626442219286333933.davem@davemloft.net>
        <1491594406.5800.18.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491594406.5800.18.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Fri, 07 Apr 2017 21:46:46 +0200

> On Fri, 2017-04-07 at 12:43 -0700, David Miller wrote:
>> I suspect that someone will eventually give us a hard time about the
>> strings wrt. internationalization. :-) It's solvable at least
>> partially in userspace I suppose.
> 
> I tend to think of the strings more of a debugging aid, but that's a
> good point.
> 
> Perhaps we should have a macro that has the strings - similar to the
> inline function I put into netlink - but if we make that a macro we can
> put the strings into a separate section to be able to find them more
> easily for later translation, and optionally even omit them entirely
> (to satisfy the kernel tinification folks)?

One idea.  We use the macro thing to generate a "netlink.pot" file and
then some userland tree can contain the latest netlink.pot and the
translations.

I'm suggesting it this way because whilst putting the netlink.pot file
in the kernel tree is probably OK, putting all the translation there
might not be.
