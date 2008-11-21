From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must follow a specific format
Date: Fri, 21 Nov 2008 13:19:07 -0800
Message-ID: <9929d2390811211319v1905b74ey329c4cd1001ac7ce@mail.gmail.com>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	 <20081121190110.32313.43591.stgit@gitlost.lost>
	 <1227294295.23438.17.camel@localhost.localdomain>
	 <9929d2390811211123i284a3939lf96e53208ee8357e@mail.gmail.com>
	 <20081121121625.6cdf22b6@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Bruce Allan" <bruce.w.allan@intel.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.243]:57110 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYKUVTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 16:19:10 -0500
Received: by hs-out-0708.google.com with SMTP id 4so531339hsl.5
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 13:19:07 -0800 (PST)
In-Reply-To: <20081121121625.6cdf22b6@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 12:16 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 21 Nov 2008 11:23:42 -0800
> "Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:
>
>> On Fri, Nov 21, 2008 at 11:04 AM, Dan Williams <dcbw@redhat.com> wrote:
>> > On Fri, 2008-11-21 at 11:01 -0800, Jeff Kirsher wrote:
>> >> From: Bruce Allan <bruce.w.allan@intel.com>
>> >>
>> >> The system log messages created on a link status change need to follow a
>> >> specific format to work with tools some customers use.
>> >
>> > Um, shouldn't those tools be listening to netlink for carrier events, or
>> > are these tools run on a separate machine using on some later date using
>> > the logs from the machine with the e1000e?
>> >
>> > Dan
>> >
>>
>> From my understanding these tools are looking at the logs and that is
>> why we need to have a consistent log message.
>>
>
> These tools are tied to a specific driver (yours), because not all drivers
> generate a message or the same format message. This may be okay for Intel
> but is really stupid design...

I have not checked all of the drivers, but I do see that our driver
does follow what others driver (e.g. tg3, starfire) are doing.  I
would be open for standardizing on what messages get generated and in
what format.

I am sure that would help third parties generate tools that would work
with every driver.


> It would be good if link state transitions generated uevents (online/offline).
> Then udev, hal and others could use that without netlink.
> --

Again, I would be open to any standardization so that all drivers
would deal with link up/down messages in the same manner.

-- 
Cheers,
Jeff
