From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Thu, 29 Mar 2012 14:19:31 -0700
Message-ID: <20120329211931.GH29342@merlins.org>
References: <20120329163800.GH24933@merlins.org> <1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333044575.2656.1.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2012 at 07:09:35PM +0100, Ben Hutchings wrote:
> On Thu, 2012-03-29 at 09:38 -0700, Marc MERLIN wrote:
> [...]
> > Below are some sysreq dumps I took (syslog to local disk was still
> > working fine). I know I have Tainted 'G', and I have no idea where that
> > came from, sorry :-/
> [...]
> 
> 'G' isn't a taint flag, but the following 'O' is; it means you have one
> or more out-of-tree modules loaded.  Care to tell us what they are?

All I can think of is virtualbox, but I'm almost certain I did not have
virtualbox loaded (i.e. modules disabled so they wouldn't load) for my first
test with wired ethernet (yes, I know that virtualbox modules are known 
for causing problems).

Ah, yes, I had another out of tree module:
http://www.thinkwiki.org/wiki/Tp_smapi
(on thinkpad W500)

Module                  Size  Used by
hdaps                  13616  1 
tp_smapi               23531  0 
thinkpad_ec            12857  2 hdaps,tp_smapi

So, I suppose the next step is to reproduce without those modules loaded,
which I'll do next.

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
