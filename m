From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Sat, 25 May 2013 16:37:14 -0500
Message-ID: <20130525213714.GA2843@lintop>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
 <20130525151347.GB25744@lintop.rgmadvisors.com>
 <CAJZOPZJm94XLw55kREardA-rY+AA4zYSPO7mtOZL822i7pyK=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57226 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094Ab3EYVh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 17:37:26 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd20so524154obb.33
        for <netdev@vger.kernel.org>; Sat, 25 May 2013 14:37:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJm94XLw55kREardA-rY+AA4zYSPO7mtOZL822i7pyK=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 25, 2013 at 10:41:39PM +0300, Or Gerlitz wrote:
> On Sat, May 25, 2013 at 6:13 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> [...]
> > 5. Debugging I noticed that tcpdump on machine #1 or #2 caused them to
> > suddenly receive data, and simply putting the interface in promiscuous
> > mode had the same result.  I rebooted both machine #1 and #2 several
> > times and each time they had the same issue.  I then rebooted them
> > back into 3.4 and they both functioned as expected and received data
> > on all 350 groups.  Rebooted them both back into 3.10 and they were
> > both still broken.  This is when I sent my initial email to netdev.
> [..]
> 
> Shawn, thanks for all the details, just one small confirmation, when
> you moved from 3.4 to 3.10 have you done ANY change to your app? e.g
> do you still use the same QP type (UD) or moved to RAW PACKET?

No modifications have been made to the application.  In this case I'm
using plain old UDP multicast sockets over 10g Ethernet.

--
Shawn
