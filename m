From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 07 Nov 2008 07:00:05 -0500
Message-ID: <49142DC5.8080803@garzik.org>
References: <490080F1.1060107@t2data.se> <4913FBB9.70407@garzik.org> <200811071244.17221.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Per Hallsmark <per.hallsmark@t2data.se>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, david-b@pacbell.net
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46171 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273AbYKGMAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 07:00:19 -0500
In-Reply-To: <200811071244.17221.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> Am Freitag, 7. November 2008 09:26:33 schrieb Jeff Garzik:
>> I pondered taking the easy route of fixing this by surrounding the 
>> auto_pm reference with an ifdef, but it seems like usbnet could use a 
>> bit more thought -- it is questionable whether usbnet_suspend/resume 
>> should be built at all, if !CONFIG_PM, even though they are exported.
> 
> As this is a generic problem, shouldn't we get the compiler to do
> this for us?

Can you be more specific?

	Jeff



