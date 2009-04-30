From: Matthew Jakeman <matt@evolution-systems.co.uk>
Subject: Module For Intercepting Fully Constructed IPv6 Packets
Date: Thu, 30 Apr 2009 22:20:47 +0100
Message-ID: <49FA162F.4010306@evolution-systems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55548 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757466AbZD3VUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 17:20:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am pondering attempting to write a module that will allow me to 
intercept an IPv6 packet once it has been fully constructed (so just 
before it gets passed to the output interface). The point of this is so 
that I can play around with the packets construction however I please to 
try out a few things.

I have successfully implemented one version of my code on FreeBSD. 
However this is done directly inside the kernel and I would like to 
attempt a Linux implementation as a module for greater flexibility.

I have only just started looking into this and was wondering if anyone 
could give me any pointers on how I might be able to achieve this. I am 
fairly new in the world of Linux kernel hacking with most of my previous 
experience being working with the FreeBSD kernel.

Any pointers will be much appreciated.

Cheers
Matt
