From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] linux-firmware: Add a new bnx2x FW 7.0.20.0
Date: Tue, 14 Jun 2011 11:04:18 +0100
Message-ID: <1308045859.3450.6.camel@i7.infradead.org>
References: <201106141241.40764.vladz@broadcom.com>
	 <1308044887.3450.4.camel@i7.infradead.org>
	 <201106141257.40621.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40704 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab1FNKEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 06:04:20 -0400
In-Reply-To: <201106141257.40621.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-14 at 12:57 +0300, Vlad Zolotarov wrote:
> 
> What do u mean? I do have put the ihex files under the net-next kernel
> tree at the regular location plus I updated the the kernel's
> firmware/WHENCE and firmware/Makefile files and of course I ran a
> functionality tests for the driver after all patches and with the new
> firmware.

Ah, there lies your problem.

Never put new firmware into the kernel source tree. It doesn't belong
there.

In the linux-firmware tree we store the *binary* files, which go
directly into /lib/firmware as-is.

-- 
dwmw2

