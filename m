From: Alessandro Zummo <alessandro.zummo@towertech.it>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values:
 maclist
Date: Mon, 20 Feb 2006 14:22:58 +0100
Message-ID: <20060220142258.7299170c@inspiron>
References: <20060220010113.GA19309@deprecation.cyrius.com>
	<20060220014735.GD4971@stusta.de>
	<20060220030146.11f418dc@inspiron>
	<43F9B32B.3090203@cantab.net>
	<20060220135718.038b675b@inspiron>
	<20060220130203.GA22147@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <dvrabel@cantab.net>, Adrian Bunk <bunk@stusta.de>,
	Martin Michlmayr <tbm@cyrius.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030219AbWBTN3R@vger.kernel.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20060220130203.GA22147@flint.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Feb 2006 13:02:03 +0000
Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> >  for this driver which we are working on.. for example,
> >  some Cirrus Logic ARM based chips (ep93xx) have an ethernet device
> >  that could benefit from that.
> 
> An alternative solution (suggested in the past) would be to have a
> generic kernel command line option such as: mac=<netdev>,<macaddr>
> 
> It nicely solves the "no mac address" issue in a lot (if not all)
> of the cases.

 That would help, but it can't easily be implemented when you are
 targeting consumer devices like nas, routers et al which already
 have been widely deployed.

 I know that the solution would be to fix the bootloader, but
 Joe Average is a little bit scared of reflashing it.

 A maclist-alike system could help to solve that situation.

-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Turin, Italy

  http://www.towertech.it
