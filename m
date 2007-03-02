From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 02 Mar 2007 08:17:44 -0800
Message-ID: <45E84E28.9060402@intel.com>
References: <20070227110233.GA14138@havoc.gtf.org> <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org> <45E7D516.30401@intel.com> <Pine.LNX.4.64.0703020751290.3953@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40448 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992573AbXCBQSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:18:21 -0500
In-Reply-To: <Pine.LNX.4.64.0703020751290.3953@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Thu, 1 Mar 2007, Kok, Auke wrote:
> and lspci says:
> 
> 	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)

> DMI info isn't very interesting, but it's an all-Intel board:
> 
> so it's all-intel chipset, all-intel board, and all-intel BIOS ;)

It's like the devil plays with it. We just discussed adding a piece of text 
about this issue to our README.

>> there have been problems reported with AMT2 on several chipsets (AMT2 is
>> not supported under linux, unlike AMT1), and having it enabled in the BIOS
>> produces this phenomenon.
> 
> Is there some way to at least disable AMT2 from the Linux driver (ie I 
> assume this is some issue of Intel not documenting it all - but maybe you 
> can add a "turn off that bit" to the affected chip).

Our suggestion is (IOW will be in the README) to turn AMT2 off completely in the 
BIOS, but I'll investigate if your suggestion is possible. It may be another 
workaround but this one indeed hurts.

> If I'm not the only one to see it, it's obviously not just my personal 
> ethernet switch bug, but apparently the e1000 becoming confused by some 
> link detection event (and powering down the switch probably just gets it 
> out of its confusion).

No, this fits the description perfectly of this issue. I'll get right on it and 
owe you a patch for the `e1000: not ready for irq` problem too, which seems to 
hold out after tests...

Cheers,

Auke
