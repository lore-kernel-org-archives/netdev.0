From: Ani Sinha <ani@arista.com>
Subject: route/max_size sysctl in ipv4
Date: Mon, 5 Jan 2015 15:48:11 -0800
Message-ID: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:48235 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbAEXsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 18:48:32 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so3431846igb.3
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 15:48:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all :

Please see : http://lxr.free-electrons.com/source/Documentation/networking/ip-sysctl.txt

I am looking at the code and it looks like since the route cache for
ipv4 was removed from the kernel, this sysctl parameter no longer
serves the same purpose. It does not look like it is even used in the
ipv4/route.c module. Is there an equivalent sysctl parameter limiting
the number of route entries in the kernel? Or is there now no
mechanism to limit the number of route entries?

Please someone enlighten me.

Thanks a lot in advance,
ani
