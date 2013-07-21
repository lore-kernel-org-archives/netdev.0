From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Sun, 21 Jul 2013 15:48:23 +0100
Message-ID: <1374418103.16533.69.camel@deadeye.wl.decadent.org.uk>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
	 <20130711203938.GA4078@minipsycho.orion>
	 <20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
	 <CAJZOPZL7MVBphUvojJ7RjnF8EYVyMNgr4zta2_A8VZw7bKkRaQ@mail.gmail.com>
	 <20130721072455.GA1944@minipsycho.orion>
	 <CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, <Narendra_K@dell.com>,
	<netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9316 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537Ab3GUOse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 10:48:34 -0400
In-Reply-To: <CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-07-21 at 14:14 +0300, Or Gerlitz wrote:
> On Sun, Jul 21, 2013 at 10:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> [...]
> 
> Sorry, I missed that fact that initially you responded on this thread
> 
> > The value could be anything. But note that you have to have different
> > values for card1-port1,2 and card2-port1,2
> 
> why?

The intent is to identify physical ports uniquely, so userland can tell
whether two devices are backed by the same physical port.

But there's no requirement on the format, so you could ensure that one
byte of this identifier is the port number on the board.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
