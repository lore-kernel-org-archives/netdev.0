From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: NETDEV WATCHDOG: eth2: transmit timed out with 3c905C-TX
Date: Tue, 23 May 2006 22:58:42 +0200
Message-ID: <20060523205842.GC18008@bayes.mathematik.tu-chemnitz.de>
References: <20060405175033.GE16850@bayes.mathematik.tu-chemnitz.de> <BAY103-F2462FDDB9BC08C70A15B89B29B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:56964 "EHLO
	lana.hrz.tu-chemnitz.de") by vger.kernel.org with ESMTP
	id S932201AbWEWU6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 16:58:43 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F2462FDDB9BC08C70A15B89B29B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2006 at 03:36:35PM +0200, Marco Berizzi wrote:
> Steffen Klassert wrote:
> 
> >On Wed, Apr 05, 2006 at 06:33:18PM +0200, Marco Berizzi wrote:
> >> Hello everybody.
> >> I'm getting these errors (with packet/connectivity loss) on
> >> our firewall after I have plugged in a 3c905C nic. Linux is
> >> Slackware 10.2 with vanilla 2.6.16.1.
> >>
> >> Hints?
> >>
> >> PS: I have temporary resolved the problem running 'ifconfig
> >> eth2 down' and 'ifconfig eth2 up'
> >>
> >> Apr  5 17:47:07 Teti kernel: eth2: Resetting the Tx ring pointer.
> >> Apr  5 17:47:47 Teti last message repeated 4 times
> >> Apr  5 17:48:57 Teti last message repeated 7 times
> >> Apr  5 17:49:57 Teti last message repeated 6 times
> >> Apr  5 17:50:57 Teti last message repeated 6 times
> >>
> >> Apr  5 17:47:07 Teti kernel: NETDEV WATCHDOG: eth2: transmit timed out
> >
> >There were some problems of this kind with 10base2 networks in 2.6.16.
> >Could you please try whether 2.6.17-rc1 has this problems too?
> 
> [Sorry for the very huge delay, but after 2.6.17-rc1 upgrade
> xfs filesystem crashed].
> 
> Same problem here with 2.6.17-rc3-git18. Running ifconfig
> eth2 down and ifconfig eth2 up resolves the problem for
> a while.

Actually I have not really an idea what is going on here,
but increasing the debug level could give some more informations.
Setting debug=4 is a good start.
Did you try older kernel versions too?

Steffen
