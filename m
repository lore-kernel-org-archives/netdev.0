From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Tue, 19 Dec 2006 15:51:33 -0800
Message-ID: <20061219155133.20132824@freekitty>
References: <20061219185223.GA13256@srcf.ucam.org>
	<200612191959.43019.david-b@pacbell.net>
	<20061220042648.GA19814@srcf.ucam.org>
	<200612192114.49920.david-b@pacbell.net>
	<20061220053417.GA29877@suse.de>
	<20061220055209.GA20483@srcf.ucam.org>
	<1166601025.3365.1345.camel@laptopd505.fenrus.org>
	<20061220125314.GA24188@srcf.ucam.org>
	<1166621931.3365.1384.camel@laptopd505.fenrus.org>
	<20061220143134.GA25462@srcf.ucam.org>
	<1166629900.3365.1428.camel@laptopd505.fenrus.org>
	<20061220144906.7863bcd3@dxpl.pdx.osdl.net>
	<4589C945.3050105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:49773 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161025AbWLTXwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 18:52:15 -0500
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4589C945.3050105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Dec 2006 15:37:41 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> > There are two different problems:
> > 
> > 1) Behavior seems to be different depending on device driver
> >    author. We should document the expected semantics better.
> > 
> >    IMHO:
> > 	When device is down, it should:
> > 	 a) use as few resources as possible:
> > 	       - not grab memory for buffers
> > 	       - not assign IRQ unless it could get one
> > 	       - turn off all power consumption possible
> > 	 b) allow setting parameters like speed/duplex/autonegotiation,
> >             ring buffers, ... with ethtool, and remember the state
> > 	 c) not accept data coming in, and drop packets queued
> 
> What implications does c have for something like tcpdump?
> 
> rick jones

None, you can bring up the device without actually assigning an address to it.

-- 
Stephen Hemminger <shemminger@osdl.org>
