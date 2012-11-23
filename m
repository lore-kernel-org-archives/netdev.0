From: =?ISO-8859-1?Q?St=E9phane_ANCELOT?= <sancelot@free.fr>
Subject: Fwd: Re: RTL 8169  linux driver question
Date: Fri, 23 Nov 2012 20:14:37 +0100
Message-ID: <50AFCB1D.8080002@free.fr>
References: <50AFC971.7010103@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sancelot@numalliance.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:59713 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753681Ab2KWTOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 14:14:47 -0500
In-Reply-To: <50AFC971.7010103@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I have got a question regarding RTL8169 driver.

I have an adapted version of this driver for a realtime linux kernel and 
  a 8168/811B rev 2 component (as listed by lspci).

I had problem with it, my application sends a frame that is immediately 
transmitted back by some slaves, there was abnormally 100us  lost 
between the send and receive call.

Finally I found it was coming from the following register setup in the 
driver :

RTL_W16(IntrMitigate, 0x5151);



Can you give me some details about it, since I do not have the RTL8169 
programming guide.

/100us is important since this component acts as an Ethercat Master 
running at 1ms./

Regards,
Stephane Ancelot

R & D department
NUMALLIANCE
http://www.numalliance.com
