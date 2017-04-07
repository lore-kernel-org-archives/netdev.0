From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:46:46 +0200
Message-ID: <1491594406.5800.18.camel@sipsolutions.net>
References: <1491591552.5800.1.camel@sipsolutions.net>
         <20170407.122053.201153373954521345.davem@davemloft.net>
         <20170407193550.GA23424@salvia>
         <20170407.124327.626442219286333933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407.124327.626442219286333933.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 12:43 -0700, David Miller wrote:
> 
> I have no strong opinions about string length.
> 
> In my opinion, I would like to believe that if someone tried to get a
> networking patch applied that emitted a rediculously long string then
> we would give them feedback about how that is not acceptable.  Right?

Agree with this, I don't really see much point in adding an extra
warning. There's an implicit (multi-KB though) limit as well in the
message size ;-)

> I suspect that someone will eventually give us a hard time about the
> strings wrt. internationalization. :-) It's solvable at least
> partially in userspace I suppose.

I tend to think of the strings more of a debugging aid, but that's a
good point.

Perhaps we should have a macro that has the strings - similar to the
inline function I put into netlink - but if we make that a macro we can
put the strings into a separate section to be able to find them more
easily for later translation, and optionally even omit them entirely
(to satisfy the kernel tinification folks)?

johannes
