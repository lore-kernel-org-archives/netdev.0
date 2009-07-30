From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: IPv6 default routes timing out?
Date: Wed, 29 Jul 2009 19:33:58 -0500
Message-ID: <1248914038.13447.17.camel@merlyn>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roland Dreier <roland@digitalvampire.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:50815 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbZG3AeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 20:34:01 -0400
Received: by yxe26 with SMTP id 26so2001692yxe.4
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 17:34:01 -0700 (PDT)
In-Reply-To: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-29 at 10:42 -0700, Roland Dreier wrote:
> I recently set up IPv6 on home home network -- openbsd 4.5 box serving
> as a router with wired and wireless ports, advertising routes via the
> openbsd rtadvd daemon.  I have no problem on boxes on the wired
> network, which gets a default route like:
> 
>     default via fe80::240:63ff:feda:3d15 dev eth0  proto kernel  metric 1024  expires 8630sec mtu 1500 advmss 1440 hoplimit 64
> 
> However on laptops on the wireless network, I've seen the route
> timeout and apparently never reappear.  This happens running both old
> kernels like 2.6.24 and also with 2.6.31-rc4, and on systems with both
> ipw2200 and iwlagn wirelss.  The symptom is that if I leave my laptop
> running, say, overnight, in the morning the ipv6 default route is
> gone.  ipv4 networking still works fine, and if I try explicit
> link-local ipv6 addresses on the laptop, they work fine too.  But the
> ipv6 internet is gone because the kernel has no idea how to route
> packets to it.
> 
> The openbsd rtadvd config is pretty basic, just:
> 
>     ral0:\  
>             :addr="2001:470:8379:2::":prefixlen#64:rltime#9000:\
>             :maxinterval#120:mininterval#60:
> 
> Any ideas as to what I'm doing wrong, or where the problem might be?

First thing I'd do is leave wireshark running overnight on the laptop
and see if the multicast router ads are making it to there.
--
John

