From: John Hughes <john@Calva.COM>
Subject: Re: patch to improve x.25 throughput negotiation
Date: Wed, 07 Apr 2010 10:39:42 +0200
Message-ID: <4BBC44CE.5080407@Calva.COM>
References: <4BB8C2CA.6040102@Calva.COM> <v2jd45a3acc1004060509u88f32fa1va0c374154806535b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:35695 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756946Ab0DGIdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:33:46 -0400
In-Reply-To: <v2jd45a3acc1004060509u88f32fa1va0c374154806535b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

andrew hendry wrote:
> I have reproduced a few ways.
> 1. X25_MASK_THROUGHPUT on the x25_subscript_struct, then call
> SIOCX25SSUBSCRIP, then call SIOCX25FACILITIES without setting the
> throughput field. Call connect.
> 2. No subscrip setting, call SIOCX25FACILITIES without setting the
> throughput field. Call connect.
> 3. No subcrip, no facilities ioctl, call connect.
>
> The patch removes the bad facility and makes the router accept the
> call for the above cases.
> I don't currently have a setup to test both direction throughput negotiation.
>   
Summary: works for you (as far as you were able to test it).

Great news!

