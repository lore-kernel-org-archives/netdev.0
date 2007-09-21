From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 18:33:39 -0400
Message-ID: <46F446C3.9050600@garzik.org>
References: <200709211201.24475.vda.linux@googlemail.com>	<200709211905.23946.vda.linux@googlemail.com>	<15775.1190399812@turing-police.cc.vt.edu>	<200709212018.06553.vda.linux@googlemail.com> <20070921220333.3b31afb5@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Vlasenko <vda.linux@googlemail.com>, Valdis.Kletnieks@vt.edu,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41974 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764757AbXIUWdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 18:33:46 -0400
In-Reply-To: <20070921220333.3b31afb5@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
>> For example, bnx2 maintainer says that driver and
>> firmware are closely tied for his driver. IOW: you upgrade kernel
>> and your NIC is not working anymore.
>>
>> Another argument is to make kernel be able to bring up NICs
>> without needing firmware images in initramfs/initrd/hard drive.
> 
> dgrs should be using the request_firmware interface. Actually dgrs is
> probably a good candidate for /dev/null

According to an earlier thread, dgrs was never really maintained, 
written for hardware that was never really distributed widely, and very 
likely hasn't had users in years... if ever.

If that picture is accurate (it's a story I was told), then I am 
definitely queueing up a deletion patch.

	Jeff



