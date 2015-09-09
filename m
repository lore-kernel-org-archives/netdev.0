From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Wed, 9 Sep 2015 17:24:48 +0200
Message-ID: <55F04F40.4040901@gmail.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de> <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34863 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbIIPYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 11:24:52 -0400
Received: by wicge5 with SMTP id ge5so159714844wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 08:24:51 -0700 (PDT)
In-Reply-To: <55EE81D8.4010008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net] r8169: Fix sleeping function called during get_stats64
http://marc.info/?l=linux-netdev&m=144180123410135&q=raw
- the noise is still present
