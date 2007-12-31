From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 20:05:16 +0100
Message-ID: <200712312005.17384.mb@bu3sch.de>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz> <200712311818.12825.mb@bu3sch.de> <64bb37e0712311037w42bae43ayb3c10b2e0310586d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Adrian Bunk" <bunk@kernel.org>, "Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:59714 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbXLaTGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 14:06:19 -0500
In-Reply-To: <64bb37e0712311037w42bae43ayb3c10b2e0310586d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 December 2007 19:37:43 Torsten Kaiser wrote:
> The base problem is that there already are many options to break
> external modules. (CONFIG_MODULES=n ;) )

Exactly. There already are enough ways to break external modules.
No need to introduce more. ;)

> The question I can't answer in this context is: Do distributions want
> to support external modules?
> Only if yes, your argument is valid. But then they could just disable
> this feature and prevent this kind of bugreports.

That's my point. Nobody will risk bugs to save a few bytes of memory.

-- 
Greetings Michael.
