From: Ramprasad K S <ksrbhat@gmail.com>
Subject: Re: vmxnet3 LROv6 performance issues
Date: Wed, 6 Jul 2016 21:10:03 +0000 (UTC)
Message-ID: <loom.20160706T230733-0@post.gmane.org>
References: <nb448j$tf4$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36497 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755800AbcGFVPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 17:15:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1bKu9x-0001xB-7N
	for netdev@vger.kernel.org; Wed, 06 Jul 2016 23:15:05 +0200
Received: from 104.129.192.65 ([104.129.192.65])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 23:15:05 +0200
Received: from ksrbhat by 104.129.192.65 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 23:15:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernhard Schmidt <berni <at> birkenwald.de> writes:

> 
> Hi,
> 
> this started as a Debian bug
> (http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=816377), but since
> it's affecting SLES as well I'm hoping to get some help here.
> 
> I'm a bit unsure where to search here. It is definitely
> hardware/firmware and/or ESXi related. OTOH the VMware-Tools vmxnet3
> driver seems to do something very different from the in-kernel driver.
> 
> Best Regards,
> Bernhard


This is due to check sum handling issue in the vmxnet3 driver. Fix is on 
the kernel tree. 
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-
stable.git/commit/drivers/net/vmxnet3?
id=f0d437809d23999cb25207cfbe80c61e5703fdc1

I have tested the fix and confirmed to resolve the performance issue with 
LRO. 

Thanks
Ram
