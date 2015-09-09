From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 01:51:17 +0200
Message-ID: <55F0C5F5.4040101@gmail.com>
References: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de> <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com> <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de> <55F07BBC.9020308@gmail.com>
 <20150909190805.GA26699@calimero.vinschen.de> <55F0BCB6.5030508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>,
	Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37204 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbIIXvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 19:51:21 -0400
Received: by wicfx3 with SMTP id fx3so4172761wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 16:51:20 -0700 (PDT)
In-Reply-To: <55F0BCB6.5030508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH v2] r8169: Fix sleeping function called during get_stats64
http://www.spinics.net/lists/netdev/msg342490.html
- the noise is still present

Corinna, care to share kernel-core & kernel-modules you are testing with,
to unravel the Gordian Knot?
