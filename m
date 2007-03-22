From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Recent net-2.6.22 patches break bootup!
Date: Thu, 22 Mar 2007 14:27:53 -0700
Message-ID: <20070322142753.52fec3ca@localhost>
References: <20070322125955.055083236@lsx.localdomain>
	<20070322.120619.71102556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:54482 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161171AbXCVW1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 18:27:42 -0400
In-Reply-To: <20070322.120619.71102556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2007 12:06:19 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 22 Mar 2007 13:59:55 +0100
> 
> > The existing function names seem to have sentimental value to some
> > people. Same patches but without changes to the functio names.
> > 
> > Introduces an interface to register rtnetlink message handlers
> > and converts all users of rtnl_links[].
> 
> All 12 patches applied, thanks Thomas.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Something is broken now.  If I boot the system (Fedora) it gets to:

Bringing up loopback interface:  RTNETLINK answers: Invalid argument
Dump terminated
RTNETLINK answers: Invalid argument
....

tg3 device eth0 does not seem to be present, delaying initialization


then it hangs because cups won't come up without loopback

