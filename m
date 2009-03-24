From: david@lang.hm
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 11:51:29 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0903241150020.16753@asgard.lang.hm>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>  <49C9087C.5070907@trash.net> <1237912858.9082.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:40544 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698AbZCXSvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 14:51:51 -0400
In-Reply-To: <1237912858.9082.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Mar 2009, Dan Williams wrote:

> On Tue, 2009-03-24 at 17:21 +0100, Patrick McHardy wrote:
>> Matt Domsch wrote:
>>> 2) udev may have rules to change the device names.  This is most often
>>>    seen in the '70-persistent-net.rules' file.  Here we have
>>>    additional challenges:
>>>
>>> ...
>>>
>>>    c) udev may not always be able to change a device's name.  If udev
>>>       uses the kernel assignment namespace (ethN), then a rename of
>>>       eth0->eth1 may require renaming eth1->eth0 (or something else).
>>>       Udev operates on a single device instance at a time, it becomes
>>>       difficult to switch names around for multiple devices, within
>>>       the single namespace.
>>
>> I would classify this as a bug, especially the fact that udev doesn't
>> undo a failed rename, so you end up with ethX_rename. Virtual devices
>> using the same MAC address trigger this reliably unless you add
>> exceptions to the udev rules.
>
> Any particular reason the MAC addresses are the same?  This came up a
> while ago with the 'dnet' device in the thread "Dave DNET ethernet
> controller".
>
> If the MAC address isn't a UUID for the device, then *what* is?

I have seen systems (I think they were Sun boxes) where the _machine_ had 
a MAC address, and it used that same MAC on all interfaces.

this is convienient for some things, but not for others.

what's unique and reproducable is the discovery order

David Lang
