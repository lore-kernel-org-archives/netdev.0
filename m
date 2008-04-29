From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26 1/2]S2io: Fixes for multi ring support
Date: Tue, 29 Apr 2008 01:58:54 -0400
Message-ID: <4816B91E.5020707@garzik.org>
References: <Pine.GSO.4.10.10804282103270.22468-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33217 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbYD2F64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:58:56 -0400
In-Reply-To: <Pine.GSO.4.10.10804282103270.22468-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> Enable multi ring support:
> 	- Seperate ring specific data
> 	- Initialize all configured rings with equal priority.
> 	- Updated boundary check for number of Rings.
> 	- Updated per ring statistics of rx_bytes and rx_packets.
> 	- Moved lro struct from struct s2io_nic to struct ring_info.
> 	- Access respective rx ring directly in fill_rx_buffers.
> 	- Moved rx_bufs_left struct s2io_nic to struct ring_info.
> 	- Added per ring variables -  rxd_mode, rxd_count, dev, pdev. 
> -As per Jeff's suggestion merged multi ring support and fixe patches in
> to one single patch.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-2 after fixing patch description ("fixes for multi-ring 
support" is an inaccurate description, after patches were combined)


