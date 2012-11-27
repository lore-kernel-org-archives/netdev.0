From: =?UTF-8?B?5Y+26Zuo6aOe?= <sunyucong@gmail.com>
Subject: IPv4 route cache DOS attack
Date: Tue, 27 Nov 2012 15:15:55 -0800
Message-ID: <CAJygYd1OSTfpdbA57q0c6ppMtft3iB7uzo-RCXFOamGp2XVzBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:63076 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab2K0XQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 18:16:19 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so9557784vcm.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 15:16:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a linux router running kernel 3.2  that receive public ingress
packets and route them through an GRE tunnel, return packets don't go
through it

I've recently faced a serious issue with the route cache,  when the
router received spoofed source , the route cache will quickly get
exhausted (depending on the size of it) and soon the ip dst cache
overflow will be printed and network subsystem will hang until
restarted.

So, my question is, how can I turn off the route cache without
recompile the kernel or adding the  patch for removal  in 3.7?  I
tried to set

echo 0 > /proc/sys/net/ipv4/route/max_size but that has no effect at all.

And if some one can share some insight on why when dst cache
overflows, the network subsystem hangs, it would be great.

Thanks.
