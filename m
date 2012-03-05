From: Jonathan Nieder <jrnieder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlwifi WPA-TKIP crypto failure after group rekeying
Date: Sun, 4 Mar 2012 22:53:35 -0600
Message-ID: <20120305045334.GF30344@burratino>
References: <1330320802.8460.105.camel@deadeye>
 <1330333354.3483.6.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, 651199-61a8vm9lEZVf4u+23C9RwQ@public.gmane.org,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andreas Gustafsson <olangu-zAmz+4pwB1D9v+nhfvBPtQ@public.gmane.org>,
	Marco d'Itri <md-qmABPYjvHBQ@public.gmane.org>,
	Gabriel Kerneis <kerneis-klhGwnj84BUD5ynB6aAmlA@public.gmane.org>,
	Shawn Thompson <shawn-4M1tPmnoDWHhhbPYETjReHS5uNuOjpZe@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1330333354.3483.6.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Johannes Berg wrote:
> On Mon, 2012-02-27 at 05:33 +0000, Ben Hutchings wrote:

>> To summarise, a WPA-TKIP managed connection stops passing traffic and
>> the kernel log shows the message "WPA: Group rekeying".  This apparently
>> doesn't happen if the connection is in heavy use at the time or with
>> module parameter swcrypto=1.  WPA2 is not affected either.
>
> I think this is due to my patch "iwlagn: rewrite HW crypto" which
> accidentally broke key *removal* (of all things), which causes issues
> when the first GTK is removed on the second rekeying.
>
> This patch
> [...]h=5dcbf480473f6c3f06ad2426b7517038a2a18911
>
> should fix it. Wey has sent it to John
[...]
> it's also marked for stable.

Shawn Thompson (cc-ed) tested the patch against 3.2.9 and 3.3-rc6 and
found it to work[1].  What can interested people do to help usher this
into mainline?

(To recap, this was a regression introduced between 3.0 and 3.1,
presumably by v3.1-rc1~24^2~10^2^2~37.)

Thanks,
Jonathan

[1] http://bugs.debian.org/651199#147
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
