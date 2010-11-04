From: Jim <jim876@xs4all.nl>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Thu, 04 Nov 2010 21:17:59 +0100
Message-ID: <4CD314F7.4070305@xs4all.nl>
References: <4CC2DB2C.3060908@xs4all.nl> <1287862760.7499.225.camel@voxel>	 <4CC40398.6070105@xs4all.nl> <1288142302.26640.7.camel@voxel>	 <4CC84EAD.7040506@xs4all.nl> <1288825835.26640.517.camel@voxel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nolan Leake <nolan@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr7.xs4all.nl ([194.109.24.27]:3480 "EHLO
	smtp-vbr7.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab0KDUSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 16:18:07 -0400
In-Reply-To: <1288825835.26640.517.camel@voxel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2010 12:10 AM, Nolan Leake wrote:
> On Wed, 2010-10-27 at 18:09 +0200, Jim wrote:
>> Not exactly, VirtualBox calls it "bridged adapter", it 'bridges' the
>> guest machine to the tap0 interface on the host for so called host-only
>> networking.
>> See eg. http://forums.virtualbox.org/viewtopic.php?f=1&t=165
>>
>> And this sequence is now simply failing
>>   tunctl -t tap0 -u tuxuser
>>   ifconfig tap0 10.0.0.1 up
> 
> Jim,
> 
> Could you do me a favor and try this sequence:
>   tunctl -t tap0 -u tuxuser
>   <run virtualbox such that it attaches to tap0>
>   ifconfig tap0 10.0.0.1 up
> 
> Thanks,
>  - nolan
> 

Doesn't really work, virtualbox complaints loudly the tap0 device is
down, ignoring that after virtual machine is up-n-running, the
	ifconfig tap0 192.168.20.1 up
still gives  ADDRCONF(NETDEV_UP): tap0: link is not ready

Using wireshark I see guest machine is sending dhcp request but no
message is sent out from the host as before.

