From: Greg KH <greg@kroah.com>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Fri, 18 Apr 2008 09:25:13 -0700
Message-ID: <20080418162513.GA6704@kroah.com>
References: <200804161428.18066.oliver@neukum.org> <4808A88B.4010703@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37724 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbYDRQZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 12:25:34 -0400
Content-Disposition: inline
In-Reply-To: <4808A88B.4010703@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 04:56:27PM +0300, Paulius Zaleckas wrote:
> Oliver Neukum wrote:
>> Hi,
>> could you test this patch?
>> It does away with the one off serial ioctl replacing it with a standard
>> mechanism.
>> 	Regards
>> 		Oliver
>
> I have tested rfkill and it realy works, but there is two problems:
>
> - LED on the device doesn't indicate rf state... Maybe Filip knows
>   some usb command to control it?
>
> - driver creates multiple rfkill entries on sysfs... This is because
>   option device has multi endpoints (probe is called twice with GTM380):

You mean "multiple interfaces" :)

And that's correct, for this device, that is the way it was created, so
either rfkill entry should work to shut off the radio...

thanks,

greg k-h
