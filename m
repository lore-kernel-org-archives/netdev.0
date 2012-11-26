From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Re: RTL 8169  linux driver question
Date: Mon, 26 Nov 2012 09:15:19 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70BD@saturn3.aculab.com>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <sancelot@numalliance.com>
To: =?Windows-1252?Q?St=E9phane_ANCELOT?= <sancelot@free.fr>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40041 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753364Ab2KZJQf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:16:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02113-05 for <netdev@vger.kernel.org>;
 Mon, 26 Nov 2012 09:16:26 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <50AFCB1D.8080002@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I had problem with it, my application sends a frame that is immediately
> transmitted back by some slaves, there was abnormally 100us  lost
> between the send and receive call.
> 
> Finally I found it was coming from the following register setup in the
> driver :
> 
> RTL_W16(IntrMitigate, 0x5151);
> 
> Can you give me some details about it, since I do not have the RTL8169
> programming guide.

That sounds like an 'interrupt mitigation' setting - which will cause
RX interrupts to be delayed a short time in order to reduce the
interrupt load on the kernel.

There is usually an 'ethtool' setting to disable interrupt mitigation.

	David
