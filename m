From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 20:30:19 +0100
Message-ID: <49416A4B.7060205@computer.org>
References: <49415EDB.3030006@computer.org> <20081211105459.3e615be8@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:56621 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760137AbYLKTbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 14:31:17 -0500
In-Reply-To: <20081211105459.3e615be8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> I don't think there will be any difference. Linux (mainline) doesn't
> do TOE. It does do segmentation offload, and any driver that can
> do segmentation offload enables it by default.

Stephen,

Thanks for your reply. My experience with the r8169 driver is that it 
does support rx checksumming, tx checksumming, scatter/gather and tcp 
segmentation, but out of the above only enables rx checksumming by default.

The other two ethernet drivers I have hardware for don't support any 
hardware-assisted offloads (that is: they all support generic 
segmentation offload but that isn't hardware-assisted and it is also not 
enabled by default).

Best regards, Jan
