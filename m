From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft
 reboot
Date: Fri, 14 Sep 2007 11:52:22 -0700
Message-ID: <1189795942.9540.155.camel@dell>
References: <20070913083918.GA5386@xanadu.blop.info>
 <20070913192812.GA12053@xanadu.blop.info>
 <1189716472.9540.106.camel@dell> <200709141014.20635.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>,
	"netdev" <netdev@vger.kernel.org>
To: "Ingo Oeser" <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1497 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbXINRzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 13:55:05 -0400
In-Reply-To: <200709141014.20635.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-14 at 10:14 +0200, Ingo Oeser wrote:
> Michael Chan schrieb:
> > On Thu, 2007-09-13 at 21:28 +0200, Lucas Nussbaum wrote:
> > > Erm, Wouldn't it be possible to print a warning when the driver loads,
> > > saying that the firmware is outdated ?
> > 
> > It's possible, but would require the driver to parse the version string.
> > The driver currently reports the version string for information and for
> > the human to parse it.
> 
> Yes, but most humans don't know all valid firmware versions of their 
> components.
> 
> Is it enough to parse the first number in the firmware via simple_strtoul()?

No, it's not.  We need to check the number after the '.' and possibly an
alphabet at the end as well.  Worse yet, the version may be different
for different chips.

We'll see if we can come up with a simple way to detect the problem.


