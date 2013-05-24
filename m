From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Fri, 24 May 2013 09:58:56 -0700
Message-ID: <1369414736.3301.420.camel@edumazet-glaptop>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
	 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:55312 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab3EXQ66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 12:58:58 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so4446501pbc.31
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 09:58:57 -0700 (PDT)
In-Reply-To: <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 11:34 -0500, Shawn Bohrer wrote:
> On Fri, May 24, 2013 at 10:49:31AM -0500, Shawn Bohrer wrote:
> > I just started testing the 3.10 kernel, previously we were on 3.4 so
> > there is a fairly large jump.  I've additionally applied the following
> > four patches to the 3.10.0-rc2 kernel that I'm testing:
> > 
> > https://patchwork.kernel.org/patch/2484651/
> > https://patchwork.kernel.org/patch/2484671/
> > https://patchwork.kernel.org/patch/2484681/
> > https://patchwork.kernel.org/patch/2484641/
> > 
> > I don't know if those patches are related to my issues or not but I
> > plan on trying to reproduce without them soon.
> 
> I've reverted the four patches above from my test kernel and still see
> the issue so they don't appear to be the cause.

I suggest adding in tools/testing/selftests/net tests about multicast
stuff.

It seems many NIC suffer from bugs in this area, especially when dealing
with a lot of groups.
