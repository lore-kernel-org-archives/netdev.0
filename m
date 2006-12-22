From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 19:25:55 -0600
Message-ID: <20061222012554.GA28632@lists.us.dell.com>
References: <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de> <20061220055209.GA20483@srcf.ucam.org> <1166601025.3365.1345.camel@laptopd505.fenrus.org> <20061220125314.GA24188@srcf.ucam.org> <20061220150009.1d697f15@griffin.suse.cz> <1166638371.2798.26.camel@localhost.localdomain> <20061221011526.GB32625@srcf.ucam.org> <1166670411.23168.13.camel@localhost.localdomain> <200612211827.kBLIRtqC025054@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Jiri Benc <jbenc@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:2337 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945907AbWLVBfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 20:35:19 -0500
To: Valdis.Kletnieks@vt.edu
Content-Disposition: inline
In-Reply-To: <200612211827.kBLIRtqC025054@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 21, 2006 at 01:27:55PM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 20 Dec 2006 22:06:51 EST, Dan Williams said:
> > It's also complicated because some switches are supposed to rfkill both
> > an 802.11 module _and_ a bluetooth module at the same time, or I guess
> > some laptops may even have one rfkill switch for each wireless device.
> 
> On my Dell D820, it's bios-selectable if the switch is enabled, or if
> it controls just the 802.11 card, or 802.11 and bluetooth, or just bluetooth,
> or 802.11 and mobile broadband, or ...
> 
> This way lies madness. :)
> 
> (Oddest part - said bios config screen offers the choices for bluetooth
> and mobile broadband even though the hardware config doesn't include it. ;)

In this case changing the UI based on presence (and thus the printed
docs etc.) winds up being difficult.  Think of it as an embedded
advertisement - you too could have bluetooth and mobile broadband... :-)

-Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
