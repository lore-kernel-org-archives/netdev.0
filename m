From: Bart Van Assche <bvanassche@acm.org>
Subject: Kernel 3.12: netconsole no longer working with bridged network interfaces
 ?
Date: Fri, 25 Oct 2013 09:26:10 +0200
Message-ID: <526A1D12.9010700@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yahoo.smtp.stone-is.be ([5.134.1.31]:51981 "EHLO
	yahoo.smtp.stone-is.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab3JYHgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 03:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

If I try to enable netconsole with kernel 3.12-rc5 on a non-bridged 
network interface (e.g. controlled by the virtio_net driver) that works 
fine. However, if I try to enable netconsole with kernel 3.12-rc5 on a 
bridged network interface the remote system does not receive any kernel 
messages over the network. Enabling netconsole over a bridged network 
interface works fine with every older kernel I have tried so far (e.g. 
3.11.6). Did I perhaps run into a regression ?

Thanks,

Bart.
