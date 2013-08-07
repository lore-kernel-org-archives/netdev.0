From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP Unsolicited report interval patches
Date: Wed, 7 Aug 2013 03:03:10 +0200
Message-ID: <20130807010310.GH16410@order.stressinduktion.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35888 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756402Ab3HGBDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 21:03:11 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:12PM +0100, William Manley wrote:
> 4th version of the patches.
> 
> The significant changes since last review are: 
> 
> 1. there is a new patch (2/3) as requested by Hannes.

Thanks!

> 2. the third patch now uses IN_DEV_CONF_GET in place of
>    IPV4_DEVCONF_ALL.  This means that the unsolicited report interval can
>    now be configured on an interface-by-interface basis as I'd originally
>    intended but messed up in the implementation.  One concern I have now
>    is that with this latest patch-set is that while
>    /proc/sys/net/ipv4/conf/eth0/igmp... will now have an effect 
>    /proc/sys/net/ipv4/conf/all/igmp... will not.  I'm not sure how to
>    resolve this.

Hm, it seems to be come more difficult dealing with ranges.

One way would be, to check the state bit for the devinet entry and chose the
all value always but when the state bit for the interface for this entry is
set. I'll have a look on how to do this.


>    One option would be to have a special value of -1 to mean use the
>    default so I could implement fall-back semantics.  A down-side of this
>    approach is that it makes the meaning of the knobs less clear for
>    someone browsing through the filesystem.  Another option would be to
>    remove the knob from all/ entirely, although I'm not sure how to do
>    this.  Suggestions are very much welcome :)

This seems to be confusing, at least or me. ;)

Thanks for the series! The patches are find IMHO.

Do you plan to make the corresponding changes for ipv6 or should I put that on
my todo list?

Thanks,

  Hannes
