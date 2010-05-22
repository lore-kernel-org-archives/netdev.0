From: "George B." <georgeb@gmail.com>
Subject: Re: VLANs, bonding redux: vlan state does not follow ethernet
Date: Sat, 22 May 2010 13:01:58 -0700
Message-ID: <AANLkTimxEuV-qVGsLNUSCZN5ajvclZWEO-GxSYiT7ck2@mail.gmail.com>
References: <AANLkTimxJHKjAEm7wMYObFn9U3Sc1WPRYUuFFIKwwAyD@mail.gmail.com>
	 <AANLkTim9nKSOdTW9YcrfNNJCmZoJ6t40mY_9f60GrWuG@mail.gmail.com>
	 <AANLkTimar_hs5zpvbB6iGUg3b9UqgUASqlhMtK81ccXZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56491 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758061Ab0EVUCA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 16:02:00 -0400
Received: by fxm5 with SMTP id 5so1635652fxm.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 13:01:58 -0700 (PDT)
In-Reply-To: <AANLkTimar_hs5zpvbB6iGUg3b9UqgUASqlhMtK81ccXZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 22, 2010 at 10:47 AM, George B. <georgeb@gmail.com> wrote:


> This is with both physical links up. =A0The arp monitor just causes t=
he
> links to constantly fail back and forth each arp_monitor interval.
>

I can get it to work with miimon and use_carrier=3D1 with the vlan
interface (works to the raw ethernet without the use_carrier).

It would be nice, though, for arp_monitor to actually work as by
monitoring an IP on the core switch it would allow me to detect a
failed uplink from the access switch.
