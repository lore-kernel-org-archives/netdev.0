From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Tue, 23 Jan 2007 13:46:49 -0800
Message-ID: <45B68249.90507@oracle.com>
References: <20070121210737.GE2702@osprey.hogchain.net>	<20070121183151.4be61ebf.randy.dunlap@oracle.com>	<45B43093.6060500@bellsouth.net>	<20070122200004.GA12553@dreamland.darkstar.lan>	<20070123112522.65aac61b@freekitty>	<45B67F29.4010703@garzik.org> <20070123133409.17a32128@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, shemminger@osdl.org,
	csnook@redhat.com, hch@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:11970 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965496AbXAWVxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 16:53:37 -0500
To: Stephen Hemminger <shemminger@linux-foundation.org>
In-Reply-To: <20070123133409.17a32128@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 23 Jan 2007 16:33:29 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Stephen Hemminger wrote:
>>> IMHO the MSI disabling should be removed from drivers and be done
>>> in the PCI core.
>> That is the consensus opinion.
>>
>> Currently drivers implement the MSI tests because the core PCI code 
>> hasn't been up to snuff.  I (and others) have been discouraging that, 
>> but when a user faces a choice between working and non-working network, 
>> the pragmatic solution wins.

Linus's remark (IIRC) was to not enable CONFIG_PCI_MSI then.

>> All efforts to get us to the point where we can remove the MSI tests 
>> from drivers are strongly supported...
>>
>> 	Jeff
> 
> So far, either MSI works for all devices or is broken, so it makes
> sense to have a "msi=off" boot option (if there isn't already)
> 
There is one, but it's spelled "pci=nomsi".

-- 
~Randy
