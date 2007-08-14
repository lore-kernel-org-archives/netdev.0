From: Ben Dooks <ben@fluff.org>
Subject: Re: dm9000: add set_mac_address()
Date: Tue, 14 Aug 2007 11:10:10 +0100
Message-ID: <20070814101010.GA29632@fluff.org.uk>
References: <20070812192741.GB27490@gandalf.sssup.it> <46BF9304.9080709@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Trimarchi <trimarchi@gandalf.sssup.it>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:53174 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbXHNKKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 06:10:34 -0400
Content-Disposition: inline
In-Reply-To: <46BF9304.9080709@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 07:08:52PM -0400, Jeff Garzik wrote:
> set_mac_address should not write to the SROM, as Michael noted.
> 
> The proper operations are:
> 
>     probe time:
> 	read MAC address from SROM
> 
>     dev open (interface up):
> 	write dev->dev_addr[] to RX filter (or identity) registers
> 
> EEPROM update support is available separately, via an ethtool sub-ioctl.

This sounds sensible, I am working on adding ethtool support
and should have a patch available in the next day or so.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
