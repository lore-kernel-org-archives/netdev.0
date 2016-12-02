From: Saku Ytti <saku@ytti.fi>
Subject: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 14:51:57 +0200
Message-ID: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:36407 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcLBMv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 07:51:58 -0500
Received: by mail-vk0-f47.google.com with SMTP id p9so145104420vkd.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 04:51:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

net.ipv4.conf.all.arp_filter appears not to have IPv6 counter part.
Or am I missing something? That is Linux does answer to ND queries for
unrelated interfaces by default, and I can't seem to find way to turn
that off.

Is it proper maintainership to accept changes to single protocol,
without mandating the support for other protocol having same
behavioural characteristics?

It is good that some parts for ARP and ND have common code in linux
(neighbour.c) unlike in BSD where everything seems to be
self-contained.
I'd wish that even more of ARP/ND would common, because there are
still lot of common behavioural code in ARP/ND code itself, which
requires double maintenance and are implemented by different people at
different times, so leads to different set of bugs and behaviour for
same intended behaviour.

For example this feature should be protocol agnostic, developer should
only need to develop it once for the higher level behavioural code,
without minding which IP AFI it is for. Obviously that does not
exclude ability to sysctl configure it on/off per AFI.

Thanks!
-- 
  ++ytti
