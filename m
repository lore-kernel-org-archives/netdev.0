From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 20:16:31 +0800
Message-ID: <CACVXFVNCg4mHcy+-0LGjxLninp1fXYUUnW=EHwor7K3Sh+f9nA@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<87d2u1wci6.fsf@nemi.mork.no>
	<CACVXFVO13tG606nDHth5rEA9jexj1iFHnry5ktrMpm_aGGTSvw@mail.gmail.com>
	<1762413.DH0n5NjUdu@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:36330 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab3DKMQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:16:33 -0400
In-Reply-To: <1762413.DH0n5NjUdu@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 7:54 PM, Oliver Neukum <oliver@neukum.org> wrote:
>> > Is this example
>> >  a) wrong, or
>> >  b) not applicable, or
>> >  c) to be excluded from the new API?
>>
>> IMO, it may be a) or b), and we can find many GFP_KERNEL usage
>> inside usbnet(kevent(), ...).
>
> Only in the rx path.

So it is b) since usbnet_status_start() can't be in rx path, :-)

>
>> Also (3) doesn't explain the cause. Oliver, could you give a hit?
>
> IIRC this was to cover networked file systems.

Given atomic allocation is used in rx/tx path already, and suppose
no other contexts might block rx/tx path, so is the rule still valid now?

Thanks,
-- 
Ming Lei
