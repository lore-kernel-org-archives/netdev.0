From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Sun, 20 Jan 2013 15:46:43 +0100
Message-ID: <50FC0353.8090902@gmail.com>
References: <50FBA02C.9030203@linux-ipv6.org> <20130120105058.1aee26c4@stein> <50FBC8D5.50205@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:44849 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab3ATOqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 09:46:47 -0500
In-Reply-To: <50FBC8D5.50205@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Indeed neither the device nor the lower drivers check protocol checksums.
>> But the CRCs of the encapsulating 1394 packets are checked in hardware.
>> Shall protocol checksums be verified regardless?
>
> Yes, because packets may come from off-link source.
>

Hm, I can't see any off-link packets coming from 
fwnet_finish_incoming_packet()

So I wont verify checksums in the driver.

Stephan
