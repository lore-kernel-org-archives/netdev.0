From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26 3/5]S2io: Enabling Multi ring support
Date: Fri, 25 Apr 2008 12:05:08 -0400
Message-ID: <48120134.7090402@garzik.org>
References: <Pine.GSO.4.10.10804231331360.10279-100000@guinness> <481170D1.2060700@garzik.org> <78C9135A3D2ECE4B8162EBDCE82CAD770378875D@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	netdev@vger.kernel.org, support <support@neterion.com>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54866 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757278AbYDYQFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 12:05:10 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD770378875D@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa wrote:
>> Sreenivasa Honnur wrote:
>>> Enable multi ring support:
>>> 	- Seperate ring specific data
>>> 	- Initialize all configured rings with equal priority.
>>> 	- Updated boundary check for number of Rings.
>>> 	- Updated per ring statistics of rx_bytes and rx_packets.
>>> 	- Moved lro struct from struct s2io_nic to struct ring_info.
>>>
>>> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
>>> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
>>> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
>> if multi-ring support and fixes are two separate patches, then that
>> creates a state whereby git-bisect might produce a broken driver.
> [Ram] We created two patches so they can be reviewed easily. Do you want
> us to merge the two patches and submit?

Yes.

	Jeff



