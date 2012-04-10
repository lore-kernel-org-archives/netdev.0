From: Michal Simek <monstr@monstr.eu>
Subject: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:10:54 +0200
Message-ID: <4F83EB0E.4020104@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52179 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab2DJILB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:11:01 -0400
Received: by eekc41 with SMTP id c41so1237061eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 01:10:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I have spent some time to investigate what it is causing regression on our network bechmark
and I have identified that your patch "net: more accurate skb truesize" is causing that.

I see regression especially on incoming tcp (RX) connection which is 20%. On TX I see regression till 5%.

In general microblaze systems are pretty sensitive for memory usage and working with it.
Increasing packet sizes has big impact on performance.
I was surprised that regression is so high.

 From microblaze point of view is more important to remove that performance regression
than having more accurate memory accounting. 20% performance regression is simple so high
for that.
Isn't there any other way to doing better memory accounting?
Or is there any workaround which would be possible to use?

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
