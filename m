From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 16:51:39 +0100
Message-ID: <1166629900.3365.1428.camel@laptopd505.fenrus.org>
References: <20061219185223.GA13256@srcf.ucam.org>
	 <200612191959.43019.david-b@pacbell.net>
	 <20061220042648.GA19814@srcf.ucam.org>
	 <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de>
	 <20061220055209.GA20483@srcf.ucam.org>
	 <1166601025.3365.1345.camel@laptopd505.fenrus.org>
	 <20061220125314.GA24188@srcf.ucam.org>
	 <1166621931.3365.1384.camel@laptopd505.fenrus.org>
	 <20061220143134.GA25462@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47198 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbWLTPvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 10:51:42 -0500
To: Matthew Garrett <mjg59@srcf.ucam.org>
In-Reply-To: <20061220143134.GA25462@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Yeah, I guess that's a problem. From a user perspective, the 
> functionality is only really useful if the latency is very small. I 
> think where possible we'd want to power down the chip while keeping the 
> phy up, but it would be nice to know how much power that would actually 
> cost us.


I'm no expert but afaik the PHY is the power hungry part, the rest is
peanuts. So if we can get the PHY to sleep most of the time that would
be great.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

