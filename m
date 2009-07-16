From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: TCP MD5 connections get stuck with IPV6 mapped listener
Date: Thu, 16 Jul 2009 02:40:21 +0000
Message-ID: <1247712021.7129.29.camel@Maple>
References: <20090715121119.12fc69e5@s6510>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f185.google.com ([209.85.216.185]:62815 "EHLO
	mail-px0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757057AbZGPCkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 22:40:24 -0400
Received: by pxi15 with SMTP id 15so1880551pxi.33
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 19:40:24 -0700 (PDT)
In-Reply-To: <20090715121119.12fc69e5@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-15 at 12:11 -0700, Stephen Hemminger wrote:

> While investigating some TCP MD5 issues, with BGP, broke things
> up into a simple test program found that
> if server is listening on IPV6 for TCP with MD5 key
> and client connects with IPV4 MD5 key, the connection gets stuck after
> the initial SYN-SENT, SYN-ACK.

Stephen, I put a patch out on a separate thread "[PATCH] tcp: Fix MD5
signature checking on IPv4 mapped sockets."

I tested the obvious cases using your excellent tool, but I don't have
the infrastructure for complete testing.  I expect you do.
-- 
John Dykstra
voice:           +1 651 484-1098            Yahoo IM:  jdykstra72

LinkedIn:        http://www.linkedin.com/in/JohnDykstra
Blog:            http://johndykstra.blogspot.com/ 



