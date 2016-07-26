From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Tue, 26 Jul 2016 13:55:56 +0200
Message-ID: <20160726115556.GC11538@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50944 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbcGZLz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 07:55:58 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 09:49:53AM +0000, Raju Lakkaraju wrote:
> Hello All,
> 
> I would like to introduce myself as Nagaraju Lakkaraju (Raju), is working in Microsemi Communications India Pvt. Ltd (Formerly known as Vitesse Semiconductors Limited) - Hyderabad as Sr. Staff Engineer.
> I do work on Microsemi PHY drivers development.
> Microsemi is developing the new Physical Layer (PHY) chips for Internet Of Things (IoT) products with 1 Gbps link speed. 
> As part of the development, Microsemi would like to contribute the new PHYs (i.e. VSC 8531 / VSC 8541) chip drivers in Linux Kernel Open source.
> VSC 8531 / 8541 PHYs will have the following features a part of the basic features like Auto-neg, Speed, Duplex etc.
> 1. Wake on LAN 
> 2. Auto MDIX/MDI 
> 3. Link Speed Down shift
> 4. Fast Link Failure-2
> 5. Loopbacks (FAR-END, NEAR-END and Connector)
> 6. Ethernet Packet Generator (EPG)
> 7. Serial Management Interface (SMI) Interrupt
> 8. Clock Squelch configuration (SyncE)
> 9. Jumbo Frame Support
> 10. In-line Power On Ethernet (PoE) status
> 11. Acti PHY power Management 
> 12. Energy Efficiency Ethenet (EEE)
> 13. VeriPHY (Cable Diagnostics)
> 14. LED configuration
> 15. Ring Resiliency
> 16. Start Of Frame Detection (SOF)
> 17. COMA mode 

Some interesting features. Is the datasheet publicly available?
 
> As part of Initial submission of the Linux Kernel Open source drivers,
> I developed the VSC 8531 driver basic features and built the Linux Kernel image for Beaglebone Black hardware.
> Also developed Ethtool enhancement for VSC 8531 register access functionality to test the VSC 8531 
> 
> Test Setup:
> -------------
> Hardware Details: Beaglebone Black with VSC 8531 PHY
> Software Linux Kernel version: 4.6.4
> 
> Microsemi VSC 8531 chip is mount on Beaglebone Black hardware (replaced the Microchip PHY) and tested the following features.
> 1. Auto negotiation
> 2. Speed change ( 10 Mbps, 100 Mbps and 1 Gbps)
> 3. Full/Half Duplex
> 4. Ping 
> 5. Line rate traffic with Test center
> 
> I would like you to review my code and provide me the valuable comments.
> Please find the attached git code diff patch.

I would like to review your code, but please read the SubmittingPathes
document and in particularly, the bit about attachments.

	 Andrew
