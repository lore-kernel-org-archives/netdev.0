From: Michal Simek <monstr@monstr.eu>
Subject: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 11:35:15 +0200
Message-ID: <4DAD5753.4040108@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39585 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab1DSJfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 05:35:19 -0400
Received: by bwz15 with SMTP id 15so4374224bwz.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 02:35:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to try to add NAPI support for ll_temac and look if help us to 
improve performance on Microblaze system. I would expect that bandwidth should 
be increased.
We have the second non mainline driver which use tasklets and it provides better 
  performance than mainline driver but not so big that's why I think that NAPI 
can increase performance.

Can you please point me to any driver which I could use as a template?
Or any developer guide to do so.

Do you know any other option how to improve driver performance on low speed cpu?

I have found that driver spends a lot of time on skb allocation and preallocated 
SKBs help a little bit. I have done a test where I increased number of 
preallocated BDs(SKBs) for rx to 35000 and disable new BD(SKB) allocation in 
rx_irq. 35000 BDs is setup because I need them to successfully finish netperf 
test. I have got 25% bandwidth increasing.

It will be also nice to be able to allocate several BDs(SKBs) which could be 
faster than allocate them in sequence.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
