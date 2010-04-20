From: Ben Greear <greearb@candelatech.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
 of 	outgoing connections (unable to bind ... )
Date: Tue, 20 Apr 2010 16:07:37 -0700
Message-ID: <4BCE33B9.8050101@candelatech.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45784 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0DTXHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:07:39 -0400
In-Reply-To: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2010 03:17 PM, Gaspar Chilingarov wrote:

> I would be grateful for hints where to look in the source -- may be I
> can produce some working patches for it.

I've opened 40,000 connections to/from my machine (over external interfaces)
on a slightly hacked .31 kernel.  This is 80,000 sockets total.  I bind
to local IP and port range, as well as SO_BINDTODEVICE.

I'm using a 64-bit system with 12GB of RAM, quad-core i7 3.3Ghz, etc.

It takes a lot of RAM to do this but you can probably use less RAM in user-space
than I am.  Be sure to set your socket buffer sizes small.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
