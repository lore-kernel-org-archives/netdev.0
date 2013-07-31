From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 3.10, iwlwifi 6200AGN: AP changed bandwidth in a way we can't
 support - disconnect
Date: Wed, 31 Jul 2013 16:59:13 +0200
Message-ID: <1375282753.8289.15.camel@jlt4.sipsolutions.net>
References: <20130729163452.GA454@hexapodia.org>
	 <20130731085956.GC1681@redhat.com> <20130731145737.GC31017@hexapodia.org>
	 (sfid-20130731_165746_082110_A8A42A60)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arkadiusz Miskiewicz <a.miskiewicz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130731145737.GC31017-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org> (sfid-20130731_165746_082110_A8A42A60)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 07:57 -0700, Andy Isaacson wrote:
> On Wed, Jul 31, 2013 at 10:59:56AM +0200, Stanislaw Gruszka wrote:
> > We have few reports about this. Johannes, proposed this patch
> > http://p.sipsolutions.net/9d1dd0734d2c3a7a.txt
> > 
> > Could you check if it fixes the problem for you?
> 
> I unfortunately didn't get a chance to confirm before leaving Berlin,
> but the patch Johannes posted in the other thread seems to agree with my
> analysis of the problem, and Johannes confirmed from my pcap that it
> is the same problem.

I think we have two problems - the one you have should be fixed by the
patch I posted (not the one above) but the problem Chris is running into
has a WARN_ON() and isn't fixed.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
