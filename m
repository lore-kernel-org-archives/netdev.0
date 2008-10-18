From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.27 seems to break something with DSL (fwd)
Date: Sat, 18 Oct 2008 13:09:54 +0200
Message-ID: <48F9C402.9040903@gmail.com>
References: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olon@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:1203 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbYJRLJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 07:09:17 -0400
Received: by ik-out-1112.google.com with SMTP id c30so711096ika.5
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2008 04:09:15 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olon wrote, On 10/17/2008 10:11 PM:

> 
> Hi there,

Hi,

> 
> I can confirm this issue.
> I'm using a westell dsl modem, and going from 2.6.26.5 to .27.  I found that I 
> couldn't connect to most websites either.
> This modem is in passthrough mode and not nat.
> 
> Here is a dump of my attempt to connect to port 80 on gnu.org
> 
> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
> 14:14:27.213995 IP (tos 0x0, ttl  64, id 44805, offset 0, flags [DF], proto: 
> TCP (6), length: 52) 96.246.106.2.34127 > 199.232.41.10.80: F, cksum 0x6b68 
> (correct), 1665374024:1665374024(0) ack 1967527671 win 183 <nop,nop,timestamp 
> 2701875 3655675399>

Could you let us compare such logs for working vs. not working case?
Is this eth0 connected directly to modem with ethernet? 
Could you also try to set lower mtu (eg. 1400) on eth0 and maybe this:

echo 0 > /proc/sys/net/ipv4/tcp_window_scaling

Thanks,
Jarek P.

