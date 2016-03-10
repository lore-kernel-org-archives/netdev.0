From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Question on switchdev
Date: Thu, 10 Mar 2016 10:03:05 -0500
Message-ID: <56E18CA9.5020300@ti.com>
References: <56D4BB74.2010109@ti.com> <20160229222934.GA4904@lunn.ch>
 <56D8BB61.5020500@ti.com> <56DE0A36.9090807@ti.com>
 <20160309003919.GA31963@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <jiri@resnulli.us>, <sfeldma@gmail.com>, <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:46034 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbcCJPDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 10:03:11 -0500
In-Reply-To: <20160309003919.GA31963@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2016 07:39 PM, Andrew Lunn wrote:
>> Andrew,
>>
>> >From the high level, it looks like netcp switch meets the specifications
>> of a DSA hardware. Can you point me to a specific implementation that
>> I can use as an example to implement this for netcp?
> 
> You need two parts:
> 
> A tagging implementation, in net/dsa/tag_*.c. They are all pretty
> similar, and all pretty simple.
> 
> A switch driver. driver/net/dsa/mv88e6060.c is the simplest. I would
> suggest your first submission implements similar features as to what
> this driver does. This is very minimalistic, but a good start. Once
> that is accepted, you can incrementally add more features.
> 
>      Andrew
> 
Thanks Andrew!

-- 
Murali Karicheri
Linux Kernel, Keystone
