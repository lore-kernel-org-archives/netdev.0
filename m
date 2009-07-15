From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: TCP MD5 connections get stuck with IPV6 mapped listener
Date: Wed, 15 Jul 2009 14:43:05 -0500
Message-ID: <1247686985.7129.15.camel@Maple>
References: <20090715121119.12fc69e5@s6510>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:33417 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756142AbZGOTnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 15:43:11 -0400
Received: by ewy26 with SMTP id 26so4319586ewy.37
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 12:43:10 -0700 (PDT)
In-Reply-To: <20090715121119.12fc69e5@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-15 at 12:11 -0700, Stephen Hemminger wrote:
> While investigating some TCP MD5 issues, with BGP, broke things
> up into a simple test program found that
> if server is listening on IPV6 for TCP with MD5 key
> and client connects with IPV4 MD5 key, the connection gets stuck after
> the initial SYN-SENT, SYN-ACK.

Just cause I've been burned recently....

Which kernel did you reproduce this on, and have you tried 2.6.31-rcx?

  --  John

