From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Any plan for inclusion of linux-wlan-ng ?
Date: Mon, 12 Apr 2004 21:21:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413042103.GB3670@jm.kir.nu>
References: <plopm3lll26bsg.fsf@drizzt.kilobug.org> <20040411164011.GA21257@kroah.com> <4079B313.7010907@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Ga?l Le Mignot <kilobug@freesurf.fr>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4079B313.7010907@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 11, 2004 at 05:05:23PM -0400, Jeff Garzik wrote:

> I had hoped that HostAP would be submitted, and that could form the 
> basis of a common 802.11 stack, but I haven't heard anything about that 
> in many weeks.

It will be.. WPA2 distracted me from this preparation, but I will try to
get back to cleaning up the Host AP driver for 2.6. Actually, I might
consider submitting it first without CCMP (AES-counter with CBC-MAC),
because that is the part that is likely to take most time to convert for
crypto API and this can be easily added separately.

-- 
Jouni Malinen                                            PGP id EFC895FA
