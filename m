From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: atl1c: DMA: Out of SW-IOMMU space
Date: Sat, 02 Mar 2013 18:52:46 -0800
Message-ID: <1362279166.15793.59.camel@edumazet-glaptop>
References: <CAHsu+b8JkVPbh7p7pj4u2XFJ3oA+HfxiGVJyz7TLG3FNQzBZCQ@mail.gmail.com>
	 <157393863283F442885425D2C4542856489D5748@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andre Heider <a.heider@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:49195 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3CCCwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 21:52:49 -0500
Received: by mail-da0-f47.google.com with SMTP id s35so1996641dak.34
        for <netdev@vger.kernel.org>; Sat, 02 Mar 2013 18:52:49 -0800 (PST)
In-Reply-To: <157393863283F442885425D2C4542856489D5748@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-03 at 01:48 +0000, Huang, Xiong wrote:
> There is another patch follows commit ac574804d412047e52de4dd887615cc88f58aeb0, would you have a try ?


Do you mean the following ?


BTW, f1f220ea1dda078 doesnt exist


commit 7cb08d7f3a5ea6131f4f243c2080530ac41cb293
Author: Huang, Xiong <xiong@qca.qualcomm.com>
Date:   Tue Feb 19 07:23:09 2013 +0000

    atl1c: restore buffer state
    
    in the previous commit : f1f220ea1dda078, the BUSY state of buffer is wrongly
    deleted. this patch just restore it.
    
    Signed-off-by: xiong <xiong@qca.qualcomm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
