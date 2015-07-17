From: =?UTF-8?Q?J=C3=B6rg_Pommnitz?= <jpo234@netscape.net>
Subject: Blackhole route not enough for proxy-arp
Date: Fri, 17 Jul 2015 12:33:08 +0200
Message-ID: <CAEvAWuFLexokRTSAmO70XR5S_qW3yyjmnxRo3uKi_6R2r1Lirg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m06.mx.aol.com ([64.12.143.80]:39296 "EHLO
	omr-m06.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945920AbbGQKil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 06:38:41 -0400
Received: from mtaout-aab02.mx.aol.com (mtaout-aab02.mx.aol.com [172.26.126.206])
	by omr-m06.mx.aol.com (Outbound Mail Relay) with ESMTP id B6042700308CC
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 06:33:10 -0400 (EDT)
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by mtaout-aab02.mx.aol.com (MUA/Third Party Client Interface) with ESMTPSA id 5359738000087
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 06:33:10 -0400 (EDT)
Received: by laem6 with SMTP id m6so58757902lae.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 03:33:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
it seems that a blackhole route is not enough to enable proxy arp for
the routing target.
I tried
ip route add blackhole 192.168.66.3/32
and
ip route add 192.168.66.3/32 dev lo

arping failed with the blackhole route but got responses with the
route through the loopback interface.
Is this behaviour a bug or a feature?

-- Regards
Joerg
