From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] ath: wil6210: Fix build error
Date: Sun, 21 Jul 2013 18:52:38 +0300
Message-ID: <5330916.8NnOO4SNAp@lx-vladimir>
References: <1374374808-12768-1-git-send-email-Larry.Finger@lwfinger.net> <51EBFABB.8080701@lwfinger.net> <1559869.yu0fjJXVeX@balsa>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<wil6210@qca.qualcomm.com>, Stable <stable@vger.kernel.org>
To: <thomas@fjellstrom.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:38584 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749Ab3GUPxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 11:53:04 -0400
In-Reply-To: <1559869.yu0fjJXVeX@balsa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, July 21, 2013 09:35:40 AM Thomas Fjellstrom wrote:
> If it helps, I'm running a fresh install of Debian Sid with gcc 4.8.1. I've 
> noticed that each newer successive version of gcc gets more strict with what 
> code it accepts without warning, or error. A lot of my only somewhat old code 
> tends to have a lot more warnings. Especially that signedness warning.

Yes, this is the case; I have 4.7.3

> 
> It also looked like that that driver or section of the kernel was compiling 
> with -Werror. I haven't verrified that but I remember seeing "treating all 
> warnings as errors" at one point.
> 
You are right, I have this in Makefile:
(if one turn on extra warnings with -W, there will be lots of false alarms,
that's why this ifeq())

ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
	subdir-ccflags-y += -Werror
endif

Thanks, Vladimir
