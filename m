From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Mon, 22 Jul 2013 18:48:43 +0300
Message-ID: <CAJZOPZLz9HBuOXj0hsrMOvQAVR=koL72-4GQUxY4G+tN-VKgSA@mail.gmail.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
	<20130711203938.GA4078@minipsycho.orion>
	<20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
	<CAJZOPZL7MVBphUvojJ7RjnF8EYVyMNgr4zta2_A8VZw7bKkRaQ@mail.gmail.com>
	<20130721072455.GA1944@minipsycho.orion>
	<CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
	<1374418103.16533.69.camel@deadeye.wl.decadent.org.uk>
	<20130722114556.GB4511@fedora18-dev.oslab.blr.amer.dell.com>
	<20130722114944.GA1552@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Narendra_K@dell.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:62038 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164Ab3GVPso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:48:44 -0400
Received: by mail-qa0-f47.google.com with SMTP id o19so691443qap.13
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:48:43 -0700 (PDT)
In-Reply-To: <20130722114944.GA1552@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 2:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Jul 22, 2013 at 01:46:01PM CEST, Narendra_K@Dell.com wrote:

>>Would it be useful to embed the port number at a known offset to ensure
>>uniformity across all drivers, if a driver choses to embed port number
>>as part of phys_port_id ?

> I would not do that. Just let it be meaningless number. That is best for
> security reasons as well.

What's wrong with uniformity on port number or even on the overall concept?

Or.
