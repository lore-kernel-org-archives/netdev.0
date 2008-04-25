From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26 3/5]S2io: Enabling Multi ring support
Date: Fri, 25 Apr 2008 01:49:05 -0400
Message-ID: <481170D1.2060700@garzik.org>
References: <Pine.GSO.4.10.10804231331360.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46714 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690AbYDYFtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 01:49:07 -0400
In-Reply-To: <Pine.GSO.4.10.10804231331360.10279-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> Enable multi ring support:
> 	- Seperate ring specific data
> 	- Initialize all configured rings with equal priority.
> 	- Updated boundary check for number of Rings.
> 	- Updated per ring statistics of rx_bytes and rx_packets.
> 	- Moved lro struct from struct s2io_nic to struct ring_info.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

if multi-ring support and fixes are two separate patches, then that 
creates a state whereby git-bisect might produce a broken driver.


