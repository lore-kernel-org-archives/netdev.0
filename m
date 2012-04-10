From: Michal Simek <monstr@monstr.eu>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 11:29:30 +0200
Message-ID: <4F83FD7A.5010602@monstr.eu>
References: <4F83EB0E.4020104@monstr.eu>  <1334046444.3126.12.camel@edumazet-glaptop>  <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>  <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu> <1334049896.3126.23.camel@edumazet-glaptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51664 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab2DJJ3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 05:29:35 -0400
Received: by eekc41 with SMTP id c41so1259202eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 02:29:33 -0700 (PDT)
In-Reply-To: <1334049896.3126.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 11:24 AM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 11:11 +0200, Michal Simek wrote:
>
>> ~ # cat /proc/sys/net/ipv4/tcp_rmem
>> 4096    87380   130048
>
> Are they default values, or tuned by admin ?
>
> 130048 bytes isnt enough to let TCP open its rcv window.

yep. Default value after powerup. What's wrong with that?

Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
