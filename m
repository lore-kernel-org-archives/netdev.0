From: Sam Russell <sam.h.russell@gmail.com>
Subject: MPLS decap with iproute2
Date: Tue, 8 Dec 2015 08:42:56 +1300
Message-ID: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33318 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932367AbbLGTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 14:42:57 -0500
Received: by qkdb5 with SMTP id b5so38597809qkd.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 11:42:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've had success with the iproute2 manpage example for encapsulating
outgoing traffic in MPLS, but I've not found a way to add decap routes
inbound.

I've tried "ip route -f mpls add 100 dev lo" and other variations, but I
get netlink errors back.

Has this been built yet? Is there sample config that I can try out? I'm
running a home-built 4.3 kernel + iproute2 built from head (on ubuntu
15.10) and am comfortable with perf and splashing around in the codebase if
need be.

Cheers
Sam
