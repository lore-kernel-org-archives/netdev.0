From: Michal Simek <monstr@monstr.eu>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:37:58 +0200
Message-ID: <4F83F166.4010208@monstr.eu>
References: <4F83EB0E.4020104@monstr.eu>  <1334046444.3126.12.camel@edumazet-glaptop> <1334046746.3126.13.camel@edumazet-glaptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57139 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab2DJIiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:38:03 -0400
Received: by eekc41 with SMTP id c41so1244631eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 01:38:02 -0700 (PDT)
In-Reply-To: <1334046746.3126.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 10:32 AM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 10:27 +0200, Eric Dumazet wrote:
>
>> BTW, some NIC drivers are known to provide fat skb in their rx path, and
>> need to be fixed as well. (Some others just lie about skb->truesize to
>> avoid the tcp slowdown, see my previous iwlwifi patch)
>>
>>
>
> What is the driver you currently use on your platform ?

Using Xilinx ll_temac(in mainline) and axi_emac.


Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
