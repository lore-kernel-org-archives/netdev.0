From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 21:56:02 +1100
Message-ID: <1165488962.5027.6.camel@localhost.localdomain>
References: <20061207094502.GA19479@gate.ebshome.net>
	 <20061207.015954.52181319.davem@davemloft.net>
	 <20061207101555.GB19479@gate.ebshome.net>
	 <20061207.022010.120465413.davem@davemloft.net>
	 <20061207102257.GC19479@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40814 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032019AbWLGKzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:55:22 -0500
To: Eugene Surovegin <ebs@ebshome.net>
In-Reply-To: <20061207102257.GC19479@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-07 at 02:22 -0800, Eugene Surovegin wrote:
> On Thu, Dec 07, 2006 at 02:20:10AM -0800, David Miller wrote:
> > It also just occured to me that even if you use the dummy device
> > approach, it's the dummy device's quota that will be used by the
> > generic ->poll() downcall into the driver.
> 
> Yes, that's true. That's why I made this parameter 
> Konfig-configurable. Yes, this is not as flexible as run-time 
> configuration available for a real netdev, but better than nothing and 
> nobody has complained yet :)

Can we maybe change the dummy device weight as emacs get added to a
MAL ?

Dave, the main point of my initial email was: should we provide a
routine from the net core to initialize such dummy devices properly ?
I'm a little worried that some day, the NAPI code will change and the
initialisations done by the driver will not be enough anymore...

Cheers,
Ben.



