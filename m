From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Bridge] Can linux kernel bridge forward 802.1q tagged vlan packets?
Date: Thu, 22 Aug 2013 21:58:58 -0700
Message-ID: <CAL3LdT62oN3hdrDy2DL_Mk9+vUAsRzxaSjY5O87HbHgsjG+V6Q@mail.gmail.com>
References: <20130822224453.ca93782f.skraw@ithnet.com>
	<20130822234941.4affc863@catus>
	<20130822151941.301cd36a@nehalam.linuxnetplumber.net>
	<20130823062234.c34a6da6.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Marek Kierdelewicz <marek@piasta.pl>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephan von Krawczynski <skraw@ithnet.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:51983 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab3HWE7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 00:59:00 -0400
Received: by mail-oa0-f54.google.com with SMTP id o6so256615oag.13
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 21:58:59 -0700 (PDT)
In-Reply-To: <20130823062234.c34a6da6.skraw@ithnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Carolyn Wyborny (igb maintainer) and Mitch Williams (igbvf maintainer)...

On Thu, Aug 22, 2013 at 9:22 PM, Stephan von Krawczynski
<skraw@ithnet.com> wrote:
> On Thu, 22 Aug 2013 15:19:41 -0700
> Stephen Hemminger <stephen@networkplumber.org> wrote:
>
>> On Thu, 22 Aug 2013 23:49:41 +0200
>> Marek Kierdelewicz <marek@piasta.pl> wrote:
>>
>> > Hi,
>> >
>> > >My general idea is to bridge tagged vlan packets from a physical
>> > >interface (intel) to a virtual interface (virtio in qemu) and not
>> > >losing the tags, so the qemu guest can use vconfig and friends to get
>> > >some vlan interfaces. Is this possible and are there any additional
>> > >steps necessary besides the usual bridge configuration?
>> >
>> > I'm using this setup with KVM virtualization (Qemu's successor). It
>> > didn't work with default nic type for guest (realtek I think) as 802.1q
>> > tags were not preserved properly in one of the directions. I don't
>> > remember specifics. Anyway using e1000 driver instead of default fixed
>> > it. Works like a charm.
>>
>> KVM e1000 Vnic doesn't do VLAN offloading at least in my experience.
>> Virtio works fine.
>
> Ok guys, here is one of the major questions in this issue:
>
> How did you manage to convince the _host_ interface driver (in my setup "igb"
> from intel) to get the vlan tagged packets from the LAN port. igb has a vlan
> filter function built in and reads _no_ tagged packets at all if the driver
> does not tell it to. And in case of "up-ing" the interface for attachment to a
> bridge it does not configure this vlan filter.
> How is this expected to work?
>
> --
> Regards,
> Stephan
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cheers,
Jeff
