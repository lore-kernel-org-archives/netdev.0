From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Mon, 22 Jul 2013 13:49:44 +0200
Message-ID: <20130722114944.GA1552@minipsycho.orion>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
 <20130711203938.GA4078@minipsycho.orion>
 <20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
 <CAJZOPZL7MVBphUvojJ7RjnF8EYVyMNgr4zta2_A8VZw7bKkRaQ@mail.gmail.com>
 <20130721072455.GA1944@minipsycho.orion>
 <CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
 <1374418103.16533.69.camel@deadeye.wl.decadent.org.uk>
 <20130722114556.GB4511@fedora18-dev.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, or.gerlitz@gmail.com,
	netdev@vger.kernel.org, john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:42000 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab3GVLts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 07:49:48 -0400
Received: by mail-ea0-f169.google.com with SMTP id h15so3793220eak.0
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 04:49:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130722114556.GB4511@fedora18-dev.oslab.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 22, 2013 at 01:46:01PM CEST, Narendra_K@Dell.com wrote:
>On Sun, Jul 21, 2013 at 08:18:23PM +0530, Ben Hutchings wrote:
>> 
>> On Sun, 2013-07-21 at 14:14 +0300, Or Gerlitz wrote:
>> > On Sun, Jul 21, 2013 at 10:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> > [...]
>> >
>> > Sorry, I missed that fact that initially you responded on this thread
>> >
>> > > The value could be anything. But note that you have to have different
>> > > values for card1-port1,2 and card2-port1,2
>> >
>> > why?
>> 
>> The intent is to identify physical ports uniquely, so userland can tell
>> whether two devices are backed by the same physical port.
>> 
>> But there's no requirement on the format, so you could ensure that one
>> byte of this identifier is the port number on the board.
>
>Would it be useful to embed the port number at a known offset to ensure
>uniformity across all drivers, if a driver choses to embed port number
>as part of phys_port_id ? 

I would not do that. Just let it be meaningless number. That is best for
security reasons as well.

>
>-- 
>With regards,
>Narendra K
>Linux Engineering
>Dell Inc.
