From: <Narendra_K@Dell.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Mon, 22 Jul 2013 04:46:01 -0700
Message-ID: <20130722114556.GB4511@fedora18-dev.oslab.blr.amer.dell.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
 <20130711203938.GA4078@minipsycho.orion>
 <20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
 <CAJZOPZL7MVBphUvojJ7RjnF8EYVyMNgr4zta2_A8VZw7bKkRaQ@mail.gmail.com>
 <20130721072455.GA1944@minipsycho.orion>
 <CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
 <1374418103.16533.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <or.gerlitz@gmail.com>, <jiri@resnulli.us>,
	<netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:23526 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930Ab3GVLqM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 07:46:12 -0400
In-Reply-To: <1374418103.16533.69.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 08:18:23PM +0530, Ben Hutchings wrote:
> 
> On Sun, 2013-07-21 at 14:14 +0300, Or Gerlitz wrote:
> > On Sun, Jul 21, 2013 at 10:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> > [...]
> >
> > Sorry, I missed that fact that initially you responded on this thread
> >
> > > The value could be anything. But note that you have to have different
> > > values for card1-port1,2 and card2-port1,2
> >
> > why?
> 
> The intent is to identify physical ports uniquely, so userland can tell
> whether two devices are backed by the same physical port.
> 
> But there's no requirement on the format, so you could ensure that one
> byte of this identifier is the port number on the board.

Would it be useful to embed the port number at a known offset to ensure
uniformity across all drivers, if a driver choses to embed port number
as part of phys_port_id ? 

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
