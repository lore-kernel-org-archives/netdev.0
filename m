From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Fri, 13 Mar 2009 07:04:28 +0200
Message-ID: <1295ed070903122204s7289f9f1jd661abb302dd48c6@mail.gmail.com>
References: <200903121946.24847.rusty@rustcorp.com.au>
	 <20090312.055235.56926675.davem@davemloft.net>
	 <200903130809.49523.rusty@rustcorp.com.au>
	 <200903131017.11572.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dcbw@redhat.com,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:49828 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672AbZCMFEb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 01:04:31 -0400
Received: by ey-out-2122.google.com with SMTP id 25so589823eya.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 22:04:28 -0700 (PDT)
In-Reply-To: <200903131017.11572.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 1:47 AM, Rusty Russell <rusty@rustcorp.com.au> =
wrote:
> On Friday 13 March 2009 08:09:49 Rusty Russell wrote:
>> On Thursday 12 March 2009 23:22:35 David Miller wrote:
>> > If the link is always on, you should make that explicit by providi=
ng
>> > a link state handler, and making sure it always returns true.
>>
>> "If". =A0We've discussed adding a virtio_net feature to indicate lin=
k status,
>> which implies that it's *not* always on.
>
> Actually, I've changed my mind.
>
> Unlike a device which *has* a carrier which we can't detect, there's =
no
> virtio_net "device" which can turn off link (not kvm/qemu, not lguest=
) without
> the pending VIRTIO_NET_S_LINK feature.

Exactly :)

>
> Here's the patch for Dave's tree; the q. is do we want to put Panteli=
s' patch
> in 2.6.29 and stable?

It would be cool to put my patch in 2.6.29 since it is not intrusive
(just a quickfix)
and then drop it in favor of the proper carrier detection / control +
your patch.

Thanks,
Pantelis
